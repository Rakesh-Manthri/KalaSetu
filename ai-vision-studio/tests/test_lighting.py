from pathlib import Path
import time
import cv2
import numpy as np
import pytest

from vision_studio import VisionStudio, EnhanceRequest, EnhanceOptions
from vision_studio.pipeline.lighting import (
    correct_lighting,
    compute_masked_luminance,
    LightingResult,
    MIN_GAIN,
    MAX_GAIN,
    MIN_GAMMA,
    MAX_GAMMA,
)
from vision_studio.pipeline.validate import validate


@pytest.fixture
def product_image_path(setup_test_fixtures):
    """Path to the product textile fixture."""
    return setup_test_fixtures / "product_textile.jpg"


@pytest.fixture
def dark_yellow_fixture():
    """Create a dark, warm/yellow-tinted synthetic product image with foreground mask."""
    h, w = 300, 400
    # Background: neutral medium gray (100, 100, 100)
    img_bgr = np.full((h, w, 3), 100, dtype=np.uint8)
    mask = np.zeros((h, w), dtype=np.uint8)

    # Foreground object: centered rectangle [60:240, 80:320]
    # Dark and yellow-tinted: BGR = [20, 70, 100] (High Red, Moderate Green, Very Low Blue)
    img_bgr[60:240, 80:320] = [20, 70, 100]
    mask[60:240, 80:320] = 255

    return img_bgr, mask


class TestLightingCorrectionUnit:
    """Unit tests for lighting, white balance, and contrast correction."""

    def test_dark_yellow_image_gets_brighter_and_color_neutral(self, dark_yellow_fixture):
        """Test that dark yellow-tinted foreground becomes brighter and less yellow."""
        img_bgr, mask = dark_yellow_fixture
        mask_bool = mask > 0

        mean_lum_before = compute_masked_luminance(img_bgr, mask_bool)
        fg_b_before = float(np.mean(img_bgr[mask_bool, 0]))
        fg_r_before = float(np.mean(img_bgr[mask_bool, 2]))
        blue_to_red_ratio_before = fg_b_before / (fg_r_before + 1e-6)

        result = correct_lighting(img_bgr, mask=mask)

        assert isinstance(result, LightingResult)
        assert isinstance(result.image, np.ndarray)
        assert result.image.dtype == np.uint8
        assert result.image.shape == img_bgr.shape

        mean_lum_after = compute_masked_luminance(result.image, mask_bool)
        fg_b_after = float(np.mean(result.image[mask_bool, 0]))
        fg_r_after = float(np.mean(result.image[mask_bool, 2]))
        blue_to_red_ratio_after = fg_b_after / (fg_r_after + 1e-6)

        # 1. Assert mean luminance increases (visibly brighter)
        assert mean_lum_after > mean_lum_before
        assert result.metadata["mean_luminance_after"] > result.metadata["mean_luminance_before"]

        # 2. Assert output is less yellow (blue channel gain raised / blue-to-red ratio increased)
        assert blue_to_red_ratio_after > blue_to_red_ratio_before
        # Gains: [R, G, B] -> Blue gain should be greater than Red gain
        r_gain, g_gain, b_gain = result.metadata["white_balance_gains"]
        assert b_gain > r_gain

    def test_background_pixels_strictly_unchanged(self, dark_yellow_fixture):
        """Test that background pixels (mask == 0) remain 100% bitwise unchanged."""
        img_bgr, mask = dark_yellow_fixture
        bg_mask = mask == 0

        result = correct_lighting(img_bgr, mask=mask)

        # Background pixels must match input exactly
        np.testing.assert_array_equal(result.image[bg_mask], img_bgr[bg_mask])

    def test_metadata_structure_and_values(self, dark_yellow_fixture):
        """Test that metadata contains all required metrics with sane values."""
        img_bgr, mask = dark_yellow_fixture
        result = correct_lighting(img_bgr, mask=mask)

        metadata = result.metadata
        assert "white_balance_gains" in metadata
        assert "gamma_applied" in metadata
        assert "mean_luminance_before" in metadata
        assert "mean_luminance_after" in metadata
        assert "duration_ms" in metadata

        # Gains list [r, g, b]
        gains = metadata["white_balance_gains"]
        assert len(gains) == 3
        for g in gains:
            assert MIN_GAIN <= g <= MAX_GAIN

        # Gamma clamped to range
        assert MIN_GAMMA <= metadata["gamma_applied"] <= MAX_GAMMA
        assert metadata["duration_ms"] > 0

    def test_deterministic_output(self, dark_yellow_fixture):
        """Test that identical input produces identical output deterministically."""
        img_bgr, mask = dark_yellow_fixture

        res1 = correct_lighting(img_bgr, mask=mask)
        res2 = correct_lighting(img_bgr, mask=mask)

        np.testing.assert_array_equal(res1.image, res2.image)
        assert res1.metadata["white_balance_gains"] == res2.metadata["white_balance_gains"]
        assert res1.metadata["gamma_applied"] == res2.metadata["gamma_applied"]

    def test_fallback_on_none_or_empty_mask(self):
        """Test that None mask or all-zero mask falls back to full-image correction without crashing."""
        img_bgr = np.full((100, 100, 3), 40, dtype=np.uint8)

        # Test with mask=None
        res_none = correct_lighting(img_bgr, mask=None)
        assert res_none.metadata["fallback_full_image"] is True
        assert compute_masked_luminance(res_none.image, np.ones((100, 100), dtype=bool)) > 40

        # Test with all-zero mask
        empty_mask = np.zeros((100, 100), dtype=np.uint8)
        res_empty = correct_lighting(img_bgr, mask=empty_mask)
        assert res_empty.metadata["fallback_full_image"] is True
        assert compute_masked_luminance(res_empty.image, np.ones((100, 100), dtype=bool)) > 40

    def test_guard_against_over_correction(self):
        """Test that already balanced/bright images are clamped and not ruined."""
        # Clean neutral mid-gray image [128, 128, 128]
        neutral_img = np.full((200, 200, 3), 128, dtype=np.uint8)
        mask = np.full((200, 200), 255, dtype=np.uint8)

        result = correct_lighting(neutral_img, mask=mask)

        # Gains should be ~1.0, gamma ~1.0
        r_gain, g_gain, b_gain = result.metadata["white_balance_gains"]
        assert pytest.approx(r_gain, abs=0.05) == 1.0
        assert pytest.approx(g_gain, abs=0.05) == 1.0
        assert pytest.approx(b_gain, abs=0.05) == 1.0
        assert pytest.approx(result.metadata["gamma_applied"], abs=0.05) == 1.0

    def test_performance_budget_under_1_second(self, product_image_path):
        """Test that lighting correction runs well within the 1-second budget."""
        img_bgr, _ = validate(product_image_path)
        h, w = img_bgr.shape[:2]
        mask = np.zeros((h, w), dtype=np.uint8)
        mask[h // 4 : 3 * h // 4, w // 4 : 3 * w // 4] = 255

        start = time.perf_counter()
        result = correct_lighting(img_bgr, mask=mask)
        duration = time.perf_counter() - start

        assert duration < 1.0  # Budget is 1s, typical is <50ms
        assert result.metadata["duration_ms"] < 1000.0


class TestApiWithLighting:
    """Integration tests for VisionStudio API with lighting stage."""

    def test_enhance_full_pipeline_through_lighting(self, product_image_path):
        """Test full enhance() pipeline up through lighting correction."""
        studio = VisionStudio()
        req = EnhanceRequest(
            image_path=str(product_image_path),
            options=EnhanceOptions(
                quality="fast",
                remove_background=True,
                correct_lighting=True,
            ),
        )
        resp = studio.enhance(req)

        assert resp.status == "success"
        assert resp.errors == []
        assert resp.processed_image_path is not None
        assert Path(resp.processed_image_path).exists()

        # Metadata should contain lighting info
        assert "lighting" in resp.metadata
        assert resp.metadata["lighting"] is not None
        assert "white_balance_gains" in resp.metadata["lighting"]
        assert "gamma_applied" in resp.metadata["lighting"]
        assert "mean_luminance_before" in resp.metadata["lighting"]
        assert "mean_luminance_after" in resp.metadata["lighting"]

    def test_enhance_with_lighting_disabled(self, product_image_path):
        """Test enhance pipeline when correct_lighting=False."""
        studio = VisionStudio()
        req = EnhanceRequest(
            image_path=str(product_image_path),
            options=EnhanceOptions(
                quality="fast",
                remove_background=True,
                correct_lighting=False,
            ),
        )
        resp = studio.enhance(req)

        assert resp.status == "success"
        assert resp.errors == []
        assert resp.metadata["lighting"] is None

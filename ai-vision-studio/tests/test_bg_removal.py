from pathlib import Path
import cv2
import numpy as np
import pytest

from vision_studio import VisionStudio, EnhanceRequest, EnhanceOptions
from vision_studio.pipeline.bg_removal import remove_background, BgRemovalResult
from vision_studio.pipeline.validate import validate
from vision_studio.models.rembg_backend import get_rembg_backend, RembgBackend
from vision_studio.utils.errors import VisionStudioError


@pytest.fixture
def product_image_path(setup_test_fixtures):
    """Path to the product textile fixture."""
    return setup_test_fixtures / "product_textile.jpg"


@pytest.fixture
def plain_image_path(setup_test_fixtures):
    """Path to a plain/uniform image."""
    plain_path = setup_test_fixtures / "plain_uniform.jpg"
    if not plain_path.exists():
        from PIL import Image
        arr = np.full((300, 400, 3), 128, dtype=np.uint8)
        img = Image.fromarray(arr, mode="RGB")
        img.save(plain_path, format="JPEG", quality=95)
    return plain_path


class TestBgRemoval:
    """Tests for background removal functionality."""

    def test_remove_background_returns_valid_result(self, product_image_path):
        """Test that remove_background returns valid BgRemovalResult for a product image."""
        image_arr, _ = validate(product_image_path)
        result = remove_background(image_arr, {"quality": "fast"})

        assert isinstance(result, BgRemovalResult)
        assert isinstance(result.image, np.ndarray)
        assert isinstance(result.mask, np.ndarray)
        assert isinstance(result.bbox, tuple)
        assert len(result.bbox) == 4
        assert isinstance(result.metadata, dict)

    def test_mask_properties(self, product_image_path):
        """Test that mask is uint8 0-255 with same H/W as input."""
        image_arr, _ = validate(product_image_path)
        h, w = image_arr.shape[:2]
        result = remove_background(image_arr, {"quality": "fast"})

        assert result.mask.dtype == np.uint8
        assert result.mask.shape == (h, w)
        assert result.mask.min() >= 0
        assert result.mask.max() <= 255
        # Mask should have both foreground (high values) and background (low values) regions
        assert np.any(result.mask > 128)
        assert np.any(result.mask < 128)

    def test_foreground_properties(self, product_image_path):
        """Test that foreground has 3 channels (BGR) and same H/W as input."""
        image_arr, _ = validate(product_image_path)
        h, w = image_arr.shape[:2]
        result = remove_background(image_arr, {"quality": "fast"})

        assert result.image.dtype == np.uint8
        assert result.image.shape == (h, w, 3)

    def test_bbox_non_empty(self, product_image_path):
        """Test that bbox is non-empty and strictly within image bounds."""
        image_arr, _ = validate(product_image_path)
        h, w = image_arr.shape[:2]
        result = remove_background(image_arr, {"quality": "fast"})

        x, y, bw, bh = result.bbox
        assert bw > 0
        assert bh > 0
        assert 0 <= x < w
        assert 0 <= y < h
        assert x + bw <= w
        assert y + bh <= h

    def test_metadata_contains_required_fields(self, product_image_path):
        """Test that metadata contains quality, model, duration_ms."""
        image_arr, _ = validate(product_image_path)
        result = remove_background(image_arr, {"quality": "fast"})

        assert "quality" in result.metadata
        assert "model" in result.metadata
        assert "duration_ms" in result.metadata
        assert result.metadata["quality"] == "fast"
        assert result.metadata["model"] in ("u2net", "u2netp")
        assert result.metadata["duration_ms"] > 0

    def test_singleton_backend_reuse(self, product_image_path):
        """Test that two calls reuse the same backend instance (singleton)."""
        image_arr, _ = validate(product_image_path)

        backend1 = get_rembg_backend()
        backend2 = get_rembg_backend()
        assert backend1 is backend2

        # Two predictions should reuse loaded session without reloading
        result1 = remove_background(image_arr, {"quality": "fast"})
        result2 = remove_background(image_arr, {"quality": "fast"})

        assert result1.metadata["model"] == result2.metadata["model"]
        assert isinstance(result1.metadata["duration_ms"], (int, float))
        assert isinstance(result2.metadata["duration_ms"], (int, float))

    def test_empty_mask_handling_raises_clean_error(self, monkeypatch):
        """Test that empty/near-empty mask raises VisionStudioError with EMPTY_MASK."""
        backend = get_rembg_backend()
        # Mock backend.predict to simulate a zero mask
        monkeypatch.setattr(
            backend,
            "predict",
            lambda img, quality="balanced": (
                np.zeros_like(img),
                np.zeros(img.shape[:2], dtype=np.uint8),
            ),
        )

        test_img = np.zeros((100, 100, 3), dtype=np.uint8)
        with pytest.raises(VisionStudioError) as exc_info:
            remove_background(test_img)

        assert exc_info.value.code == "EMPTY_MASK"
        assert exc_info.value.stage == "bg_removal"

    def test_different_quality_levels(self, product_image_path):
        """Test that different quality levels work and produce different model/size configs."""
        image_arr, _ = validate(product_image_path)

        for quality in ["fast", "balanced", "high"]:
            result = remove_background(image_arr, {"quality": quality})
            assert result.metadata["quality"] == quality
            assert result.metadata["model"] in ("u2net", "u2netp")
            assert result.metadata["duration_ms"] > 0

    def test_quality_fast_uses_u2netp(self, product_image_path):
        """Test that 'fast' quality uses u2netp model."""
        image_arr, _ = validate(product_image_path)
        result = remove_background(image_arr, {"quality": "fast"})
        assert result.metadata["model"] == "u2netp"

    def test_quality_balanced_high_use_u2net(self, product_image_path):
        """Test that 'balanced' and 'high' quality use u2net model."""
        image_arr, _ = validate(product_image_path)
        result_balanced = remove_background(image_arr, {"quality": "balanced"})
        result_high = remove_background(image_arr, {"quality": "high"})
        assert result_balanced.metadata["model"] == "u2net"
        assert result_high.metadata["model"] == "u2net"


class TestApiWithBgRemoval:
    """Integration tests for VisionStudio API with background removal."""

    def test_enhance_with_bg_removal_fast(self, setup_test_fixtures):
        """Test full enhance pipeline with background removal (fast quality)."""
        product_path = setup_test_fixtures / "product_textile.jpg"

        studio = VisionStudio()
        req = EnhanceRequest(
            image_path=str(product_path),
            options=EnhanceOptions(quality="fast", remove_background=True),
        )
        resp = studio.enhance(req)

        assert resp.status == "success"
        assert resp.errors == []
        assert resp.processed_image_path is not None
        assert Path(resp.processed_image_path).exists()

        # Check metadata
        assert "bg_removal" in resp.metadata
        assert resp.metadata["bg_removal"] is not None
        assert resp.metadata["bg_removal"]["quality"] == "fast"
        assert "duration_ms" in resp.metadata["bg_removal"]

    def test_enhance_with_bg_removal_disabled(self, setup_test_fixtures):
        """Test enhance with background removal disabled."""
        product_path = setup_test_fixtures / "product_textile.jpg"

        studio = VisionStudio()
        req = EnhanceRequest(
            image_path=str(product_path),
            options=EnhanceOptions(quality="fast", remove_background=False),
        )
        resp = studio.enhance(req)

        assert resp.status == "success"
        assert resp.errors == []
        assert resp.metadata.get("bg_removal") is None

    def test_enhance_with_invalid_image_returns_error(self, setup_test_fixtures):
        """Test that invalid image returns error without crashing."""
        corrupt_path = setup_test_fixtures / "corrupt.jpg"

        studio = VisionStudio()
        req = EnhanceRequest(image_path=str(corrupt_path))
        resp = studio.enhance(req)

        assert resp.status == "error"
        assert len(resp.errors) == 1
        assert resp.errors[0]["code"] == "INVALID_IMAGE"

    def test_enhance_empty_mask_returns_clean_error(self, setup_test_fixtures, monkeypatch):
        """Test that an empty mask produces a clean STAGE_FAILED/EMPTY_MASK error response."""
        product_path = setup_test_fixtures / "product_textile.jpg"
        backend = get_rembg_backend()
        monkeypatch.setattr(
            backend,
            "predict",
            lambda img, quality="balanced": (
                np.zeros_like(img),
                np.zeros(img.shape[:2], dtype=np.uint8),
            ),
        )

        studio = VisionStudio()
        req = EnhanceRequest(
            image_path=str(product_path),
            options=EnhanceOptions(quality="fast", remove_background=True),
        )
        resp = studio.enhance(req)

        assert resp.status == "error"
        assert resp.processed_image_path is None
        assert len(resp.errors) == 1
        assert resp.errors[0]["code"] == "EMPTY_MASK"
        assert resp.errors[0]["stage"] == "bg_removal"
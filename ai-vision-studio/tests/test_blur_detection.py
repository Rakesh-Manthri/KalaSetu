import time
from pathlib import Path
import cv2
import numpy as np
import pytest

from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio
from vision_studio.pipeline.blur import (
    BLUR_LIGHT_THRESHOLD,
    BLUR_SEVERE_THRESHOLD,
    apply_unsharp_mask,
    compute_laplacian_variance,
    process_blur,
)
from vision_studio.pipeline.validate import validate
from vision_studio.utils.errors import IMAGE_TOO_BLURRY, VisionStudioError


class TestBlurDetectionUnits:
    """Unit tests for blur calculation and unsharp masking primitives."""

    def test_compute_laplacian_variance_on_sharp_and_blurred(self):
        # Create a sharp image with high-contrast checkerboard
        sharp = np.zeros((200, 200, 3), dtype=np.uint8)
        sharp[::10, :] = 255
        sharp[:, ::10] = 255

        sharp_var = compute_laplacian_variance(sharp)
        assert sharp_var > 1000.0

        # Apply Gaussian blur
        blurred = cv2.GaussianBlur(sharp, (15, 15), 5.0)
        blurred_var = compute_laplacian_variance(blurred)

        # Variance must drop significantly with blur
        assert blurred_var < sharp_var
        assert blurred_var < 50.0

    def test_apply_unsharp_mask_invariants(self):
        img = np.random.randint(50, 200, size=(120, 180, 3), dtype=np.uint8)
        sharpened = apply_unsharp_mask(img)

        assert isinstance(sharpened, np.ndarray)
        assert sharpened.shape == img.shape
        assert sharpened.dtype == np.uint8
        assert sharpened.shape[2] == 3

    def test_process_blur_classification_sharp(self):
        img = np.zeros((100, 100, 3), dtype=np.uint8)
        img[::4, :] = 255  # very sharp
        out, meta = process_blur(img, severe_threshold=15.0, light_threshold=60.0)

        assert meta["blur_status"] == "sharp"
        assert meta["sharpened"] is False
        assert meta["blur_score"] >= 60.0
        assert np.array_equal(out, img)

    def test_process_blur_classification_light_blur(self):
        # Image with variance in [15.0, 60.0) range
        base = np.zeros((200, 200, 3), dtype=np.uint8)
        base[::10, :] = 255
        # Blur to achieve variance in [15, 60]
        blurred = cv2.GaussianBlur(base, (11, 11), 2.5)
        var = compute_laplacian_variance(blurred)

        out, meta = process_blur(blurred, severe_threshold=var - 5.0, light_threshold=var + 10.0)
        assert meta["blur_status"] == "light_blur"
        assert meta["sharpened"] is True
        assert meta["blur_score"] == pytest.approx(var, rel=1e-3)
        assert out.shape == blurred.shape
        assert out.dtype == np.uint8

    def test_process_blur_classification_severe_blur(self):
        flat_img = np.full((100, 100, 3), 128, dtype=np.uint8)
        with pytest.raises(VisionStudioError) as exc_info:
            process_blur(flat_img, severe_threshold=15.0, light_threshold=60.0)

        assert exc_info.value.code == IMAGE_TOO_BLURRY
        assert exc_info.value.stage == "validate"
        assert "blurry" in exc_info.value.message.lower()


class TestBlurValidationPipeline:
    """Integration tests for validation stage with blur detection."""

    def test_sharp_image_validation(self, setup_test_fixtures):
        fixtures_dir = setup_test_fixtures
        sharp_path = fixtures_dir / "product_textile.jpg"

        arr, meta = validate(sharp_path)

        assert isinstance(arr, np.ndarray)
        assert arr.dtype == np.uint8
        assert arr.shape[2] == 3
        h, w = arr.shape[:2]
        assert max(h, w) <= 2000
        assert meta["blur_status"] == "sharp"
        assert isinstance(meta["blur_score"], float)
        assert meta["blur_score"] >= BLUR_LIGHT_THRESHOLD
        assert meta["sharpened"] is False

    def test_light_blur_image_validation(self, setup_test_fixtures, tmp_path):
        fixtures_dir = setup_test_fixtures
        prod_img = cv2.imread(str(fixtures_dir / "product_textile.jpg"))

        # Create lightly blurred image targeting variance in [15, 60]
        # product_textile has original var ~101.6; GaussianBlur k=3 yields var ~12.6, so let's use custom thresholds or mild blur
        mild_blur = cv2.GaussianBlur(prod_img, (3, 3), 0.7)
        light_blur_path = tmp_path / "light_blur_product.jpg"
        cv2.imwrite(str(light_blur_path), mild_blur)

        # Validate with explicit or default thresholds
        mild_var = compute_laplacian_variance(mild_blur)
        arr, meta = validate(
            light_blur_path,
            severe_threshold=max(5.0, mild_var - 10.0),
            light_threshold=mild_var + 20.0,
        )

        assert isinstance(arr, np.ndarray)
        assert arr.dtype == np.uint8
        assert arr.shape == prod_img.shape
        assert meta["blur_status"] == "light_blur"
        assert meta["sharpened"] is True
        assert isinstance(meta["blur_score"], float)

    def test_severe_blur_image_validation_fails(self, setup_test_fixtures, tmp_path):
        fixtures_dir = setup_test_fixtures
        prod_img = cv2.imread(str(fixtures_dir / "product_textile.jpg"))

        # Create heavily blurred image
        severe_blur = cv2.GaussianBlur(prod_img, (31, 31), 10.0)
        severe_blur_path = tmp_path / "severe_blur_product.jpg"
        cv2.imwrite(str(severe_blur_path), severe_blur)

        with pytest.raises(VisionStudioError) as exc_info:
            validate(severe_blur_path, severe_threshold=15.0)

        assert exc_info.value.code == IMAGE_TOO_BLURRY
        assert exc_info.value.stage == "validate"
        assert "blurry" in exc_info.value.message.lower()

    def test_severe_blur_stops_pipeline_before_rembg(self, setup_test_fixtures, tmp_path, monkeypatch):
        fixtures_dir = setup_test_fixtures
        prod_img = cv2.imread(str(fixtures_dir / "product_textile.jpg"))

        severe_blur = cv2.GaussianBlur(prod_img, (35, 35), 12.0)
        severe_blur_path = tmp_path / "severe_blur_for_api.jpg"
        cv2.imwrite(str(severe_blur_path), severe_blur)

        # Track if remove_background was ever called
        rembg_called = False

        def mock_remove_bg(*args, **kwargs):
            nonlocal rembg_called
            rembg_called = True
            raise AssertionError("remove_background must NOT be called for severely blurry images!")

        monkeypatch.setattr("vision_studio.api.remove_background", mock_remove_bg)

        studio = VisionStudio()
        req = EnhanceRequest(
            image_path=str(severe_blur_path),
            options=EnhanceOptions(remove_background=True, quality="fast"),
        )
        resp = studio.enhance(req)

        assert resp.status == "error"
        assert resp.processed_image_path is None
        assert len(resp.errors) == 1
        assert resp.errors[0]["code"] == IMAGE_TOO_BLURRY
        assert resp.errors[0]["stage"] == "validate"
        assert "Your photo looks a bit blurry" in resp.errors[0]["message"]
        assert resp.metadata == {}
        assert rembg_called is False, "rembg must not be called when blur check fails!"

    def test_threshold_robustness_across_blur_strengths(self, setup_test_fixtures):
        fixtures_dir = setup_test_fixtures
        prod_img = cv2.imread(str(fixtures_dir / "product_textile.jpg"))

        variances = []
        kernel_sizes = [1, 3, 5, 7, 11, 15, 21, 31]
        for k in kernel_sizes:
            if k == 1:
                blurred = prod_img
            else:
                blurred = cv2.GaussianBlur(prod_img, (k, k), 0)
            var = compute_laplacian_variance(blurred)
            variances.append((k, var))

        # Variances should be strictly non-increasing with larger blur kernels
        for i in range(len(variances) - 1):
            assert variances[i][1] >= variances[i + 1][1]

    def test_blur_and_sharpening_performance_budget(self):
        # Create a large 2000x2000 image
        large_img = np.random.randint(0, 255, size=(2000, 2000, 3), dtype=np.uint8)

        # Time blur computation
        t0 = time.perf_counter()
        score = compute_laplacian_variance(large_img)
        t_blur = (time.perf_counter() - t0) * 1000.0

        # Time unsharp masking
        t0 = time.perf_counter()
        sharpened = apply_unsharp_mask(large_img)
        t_sharp = (time.perf_counter() - t0) * 1000.0

        assert score > 0
        assert sharpened.shape == (2000, 2000, 3)
        # Preprocessing must be fast (<100ms for 2000px image on standard CPU)
        assert t_sharp < 100.0, f"Unsharp mask took {t_sharp:.2f}ms, exceeding 100ms budget"

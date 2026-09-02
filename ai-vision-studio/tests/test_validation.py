from pathlib import Path
import numpy as np
import pytest

from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio
from vision_studio.pipeline.validate import validate
from vision_studio.utils.errors import (
    FILE_NOT_FOUND,
    IMAGE_TOO_LARGE,
    INVALID_IMAGE,
    UNSUPPORTED_FORMAT,
    VisionStudioError,
)
from vision_studio.utils.image_io import downscale_long_edge, load_image, save_image


def test_valid_jpeg_validation(setup_test_fixtures):
    """Verify that a valid JPEG loads to a uint8 BGR ndarray with long edge <= 2000."""
    fixtures_dir = setup_test_fixtures
    valid_path = fixtures_dir / "valid_sample.jpg"

    arr, meta = validate(valid_path)

    assert isinstance(arr, np.ndarray)
    assert arr.dtype == np.uint8
    assert len(arr.shape) == 3
    assert arr.shape[2] == 3  # BGR 3 channels
    h, w = arr.shape[:2]
    assert max(h, w) <= 2000

    # Verify metadata fields
    assert "orig_dims" in meta
    assert "norm_dims" in meta
    assert "format" in meta
    assert "has_alpha" in meta
    assert "blur_score" in meta
    assert "blur_status" in meta
    assert "sharpened" in meta
    assert isinstance(meta["blur_score"], (int, float))
    assert meta["blur_status"] in ("sharp", "light_blur", "severe_blur")
    assert isinstance(meta["sharpened"], bool)
    assert meta["format"] in ("jpeg", "jpg")
    assert meta["has_alpha"] is False
    assert meta["norm_dims"] == (w, h)
    assert max(meta["norm_dims"]) <= 2000


def test_nonexistent_path_error():
    """Verify that a missing file path raises FILE_NOT_FOUND."""
    fake_path = "nonexistent/path/to/missing_artisan_photo.jpg"

    with pytest.raises(VisionStudioError) as exc_info:
        validate(fake_path)

    assert exc_info.value.code == FILE_NOT_FOUND
    assert exc_info.value.stage == "validate"
    assert "not found" in exc_info.value.message.lower()


def test_corrupt_image_error(setup_test_fixtures):
    """Verify that a corrupt file raises INVALID_IMAGE."""
    fixtures_dir = setup_test_fixtures
    corrupt_path = fixtures_dir / "corrupt.jpg"

    with pytest.raises(VisionStudioError) as exc_info:
        validate(corrupt_path)

    assert exc_info.value.code == INVALID_IMAGE
    assert exc_info.value.stage == "validate"


def test_oversized_image_error(setup_test_fixtures):
    """Verify that a file exceeding max_mb raises IMAGE_TOO_LARGE."""
    fixtures_dir = setup_test_fixtures
    oversized_path = fixtures_dir / "oversized.jpg"

    with pytest.raises(VisionStudioError) as exc_info:
        validate(oversized_path, max_mb=15.0)

    assert exc_info.value.code == IMAGE_TOO_LARGE
    assert exc_info.value.stage == "validate"
    assert "exceeds limit" in exc_info.value.message


def test_unsupported_format_error(setup_test_fixtures):
    """Verify that unsupported file formats (.txt) raise UNSUPPORTED_FORMAT."""
    fixtures_dir = setup_test_fixtures
    txt_path = fixtures_dir / "unsupported.txt"

    with pytest.raises(VisionStudioError) as exc_info:
        validate(txt_path)

    assert exc_info.value.code == UNSUPPORTED_FORMAT
    assert exc_info.value.stage == "validate"


def test_transparent_png_loads_without_crash(setup_test_fixtures):
    """Verify that transparent PNG loads to BGR and reports has_alpha=True."""
    fixtures_dir = setup_test_fixtures
    png_path = fixtures_dir / "transparent.png"

    arr, meta = validate(png_path)

    assert isinstance(arr, np.ndarray)
    assert arr.shape[2] == 3  # Normalized to 3-channel BGR
    assert meta["has_alpha"] is True
    assert meta["format"] == "png"


def test_exif_orientation_handling(setup_test_fixtures):
    """Verify that EXIF orientation is transposed properly before BGR conversion."""
    fixtures_dir = setup_test_fixtures
    exif_path = fixtures_dir / "exif_rotated.jpg"

    # Created as (300, 100) with orientation=6 (90 CW) -> transposed should be (100, 300)
    arr, meta = validate(exif_path)
    h, w = arr.shape[:2]
    # Width should now be 100 and height 300 after 90 deg rotation
    assert (w, h) == (100, 300)
    assert meta["norm_dims"] == (100, 300)


def test_downscale_long_edge(setup_test_fixtures):
    """Verify that images with long edge > 2000 are scaled down proportionally."""
    fixtures_dir = setup_test_fixtures
    large_path = fixtures_dir / "large_dimension.jpg"

    arr, meta = validate(large_path, max_edge=2000)
    h, w = arr.shape[:2]

    assert max(h, w) <= 2000
    assert max(meta["norm_dims"]) <= 2000
    # Original 3000x2400 scaled down: 2000x1600
    assert (w, h) == (2000, 1600)
    assert meta["orig_dims"] == (3000, 2400)


def test_downscale_helper_unit():
    """Unit test for downscale_long_edge function."""
    small_arr = np.zeros((500, 800, 3), dtype=np.uint8)
    res_small = downscale_long_edge(small_arr, max_edge=2000)
    assert res_small.shape == (500, 800, 3)

    huge_arr = np.zeros((4000, 2000, 3), dtype=np.uint8)
    res_huge = downscale_long_edge(huge_arr, max_edge=2000)
    assert res_huge.shape == (2000, 1000, 3)


def test_save_image_helper(tmp_path):
    """Verify save_image writes a valid image file to disk."""
    arr = np.zeros((100, 100, 3), dtype=np.uint8)
    out_file = tmp_path / "subdir" / "output.png"
    result_path = save_image(arr, out_file)

    assert Path(result_path).exists()
    loaded, _ = load_image(result_path)
    assert loaded.shape == (100, 100, 3)


def test_enhance_api_with_valid_image(setup_test_fixtures):
    """Verify enhance API returns success and metadata for valid input."""
    fixtures_dir = setup_test_fixtures
    valid_path = fixtures_dir / "valid_sample.jpg"

    studio = VisionStudio()
    req = EnhanceRequest(image_path=str(valid_path))
    resp = studio.enhance(req)

    assert resp.status in ("success", "partial")
    assert resp.contract_version == "1.0"
    assert resp.errors == []
    assert "image_metadata" in resp.metadata
    assert resp.metadata["image_metadata"]["format"] in ("jpeg", "jpg")


def test_enhance_api_with_invalid_inputs(setup_test_fixtures):
    """Verify enhance API returns error responses without throwing uncaught exceptions."""
    fixtures_dir = setup_test_fixtures
    studio = VisionStudio()

    # Case 1: Nonexistent path
    resp_missing = studio.enhance({"image_path": "totally_missing.jpg"})
    assert resp_missing.status == "error"
    assert resp_missing.processed_image_path is None
    assert len(resp_missing.errors) == 1
    assert resp_missing.errors[0]["code"] == FILE_NOT_FOUND
    assert resp_missing.errors[0]["stage"] == "validate"

    # Case 2: Corrupt file
    resp_corrupt = studio.enhance(EnhanceRequest(image_path=str(fixtures_dir / "corrupt.jpg")))
    assert resp_corrupt.status == "error"
    assert len(resp_corrupt.errors) == 1
    assert resp_corrupt.errors[0]["code"] == INVALID_IMAGE

    # Case 3: Unsupported format
    resp_unsupported = studio.enhance(EnhanceRequest(image_path=str(fixtures_dir / "unsupported.txt")))
    assert resp_unsupported.status == "error"
    assert len(resp_unsupported.errors) == 1
    assert resp_unsupported.errors[0]["code"] == UNSUPPORTED_FORMAT

    # Case 4: Oversized file
    resp_oversized = studio.enhance(EnhanceRequest(image_path=str(fixtures_dir / "oversized.jpg")))
    assert resp_oversized.status == "error"
    assert len(resp_oversized.errors) == 1
    assert resp_oversized.errors[0]["code"] == IMAGE_TOO_LARGE

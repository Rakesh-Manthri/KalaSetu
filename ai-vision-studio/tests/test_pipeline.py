from pathlib import Path
import pytest
import cv2

from vision_studio import EnhanceOptions, EnhanceRequest, EnhanceResponse, VisionStudio


class TestFullPipeline:
    """Comprehensive test suite for end-to-end enhancement pipeline."""

    def test_end_to_end_valid_product_image_success(self, setup_test_fixtures):
        fixture_path = setup_test_fixtures / "product_textile.jpg"
        studio = VisionStudio()
        request = EnhanceRequest(
            image_path=str(fixture_path),
            options=EnhanceOptions(
                remove_background=True,
                correct_lighting=True,
                output_size=(1000, 1000),
                background_color="#FFFFFF",
                quality="fast",
            ),
        )

        response = studio.enhance(request)

        assert response.status == "success"
        assert response.contract_version == "1.0"
        assert response.errors == []
        assert response.processed_image_path is not None

        # Verify output image file exists and is valid 1000x1000 JPEG
        processed_file = Path(response.processed_image_path)
        assert processed_file.exists()
        img = cv2.imread(str(processed_file))
        assert img is not None
        assert img.shape == (1000, 1000, 3)

        # Verify before/after montage exists
        montage_path = response.metadata.get("montage_path")
        assert montage_path is not None
        montage_file = Path(montage_path)
        assert montage_file.exists()
        montage_img = cv2.imread(str(montage_file))
        assert montage_img is not None
        assert montage_img.shape[0] > 1000  # Height includes banner
        assert montage_img.shape[1] > 2000  # Width includes left + right panels

        # Verify metadata structure
        meta = response.metadata
        assert meta["background_removed"] is True
        assert meta["quality"] == "fast"
        assert tuple(meta["orig_dims"]) == (600, 400)  # Width, Height
        assert list(meta["processed_dims"]) == [1000, 1000]
        assert meta["duration_ms"] > 0
        assert "stages" in meta
        assert "validate" in meta["stages"]
        assert "bg_removal" in meta["stages"]
        assert "lighting" in meta["stages"]
        assert "composition" in meta["stages"]
        assert "export" in meta["stages"]

    def test_pipeline_with_custom_dimensions_and_lighting_disabled(self, setup_test_fixtures):
        fixture_path = setup_test_fixtures / "product_textile.jpg"
        studio = VisionStudio()
        request = EnhanceRequest(
            image_path=str(fixture_path),
            options=EnhanceOptions(
                remove_background=True,
                correct_lighting=False,
                output_size=(800, 800),
                background_color="#F5F5F5",
                quality="fast",
            ),
        )

        response = studio.enhance(request)
        assert response.status == "success"
        assert response.metadata["lighting"] is None
        assert list(response.metadata["processed_dims"]) == [800, 800]

    def test_pipeline_with_corrupt_image_returns_clean_error(self, setup_test_fixtures):
        corrupt_path = setup_test_fixtures / "corrupt.jpg"
        studio = VisionStudio()
        request = EnhanceRequest(image_path=str(corrupt_path))

        response = studio.enhance(request)
        assert response.status == "error"
        assert response.processed_image_path is None
        assert len(response.errors) >= 1
        assert response.errors[0]["code"] in ("CORRUPT_IMAGE", "INVALID_IMAGE")

    def test_pipeline_with_nonexistent_image_returns_clean_error(self):
        studio = VisionStudio()
        request = EnhanceRequest(image_path="nonexistent_artisan_photo.jpg")

        response = studio.enhance(request)
        assert response.status == "error"
        assert response.processed_image_path is None
        assert len(response.errors) >= 1
        assert response.errors[0]["code"] == "FILE_NOT_FOUND"

    def test_pipeline_dict_request_invocation(self, setup_test_fixtures):
        fixture_path = str(setup_test_fixtures / "product_textile.jpg")
        studio = VisionStudio()
        req_dict = {
            "image_path": fixture_path,
            "options": {
                "remove_background": True,
                "correct_lighting": True,
                "quality": "fast",
            },
        }

        response = studio.enhance(req_dict)
        assert response.status == "success"
        assert isinstance(response, EnhanceResponse)

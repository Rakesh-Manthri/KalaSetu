import pytest


def test_imports():
    """Verify that public API exports only the contract and main studio class."""
    import vision_studio

    assert hasattr(vision_studio, "VisionStudio")
    assert hasattr(vision_studio, "EnhanceRequest")
    assert hasattr(vision_studio, "EnhanceResponse")
    assert hasattr(vision_studio, "EnhanceOptions")

    # Verify __all__ export strictly matches the 4 required symbols
    assert set(vision_studio.__all__) == {
        "VisionStudio",
        "EnhanceRequest",
        "EnhanceResponse",
        "EnhanceOptions",
    }


def test_enhance_nonexistent_path_returns_error():
    """Verify enhance returns error response with FILE_NOT_FOUND when image is missing."""
    from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio

    studio = VisionStudio()
    request = EnhanceRequest(
        image_path="nonexistent/fake_image.jpg",
        options=EnhanceOptions(
            remove_background=True,
            correct_lighting=True,
            output_size=(1000, 1000),
            background_color="#FFFFFF",
            quality="balanced",
        ),
    )
    response = studio.enhance(request)

    assert response.status == "error"
    assert response.contract_version == "1.0"
    assert response.processed_image_path is None
    assert isinstance(response.metadata, dict)
    assert len(response.errors) == 1
    assert response.errors[0]["code"] == "FILE_NOT_FOUND"
    assert response.errors[0]["stage"] == "validate"


def test_enhance_valid_image_smoke(setup_test_fixtures):
    """Verify enhance returns valid response and metadata when given a real image."""
    from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio

    valid_img = setup_test_fixtures / "valid_sample.jpg"
    studio = VisionStudio()
    request = EnhanceRequest(
        image_path=str(valid_img),
        options=EnhanceOptions(quality="fast"),
    )
    response = studio.enhance(request)

    assert response.status in ("success", "partial")
    assert response.contract_version == "1.0"
    assert response.errors == []
    assert "image_metadata" in response.metadata
    assert "bg_removal" in response.metadata


def test_enhance_response_contract_fields():
    """Verify all fields and types in EnhanceResponse schema."""
    from vision_studio import EnhanceResponse

    response = EnhanceResponse(
        contract_version="1.0",
        status="success",
        processed_image_path="stub_output/product.jpg",
        metadata={"test": 123},
        errors=[],
    )

    data = response.model_dump()
    assert data["contract_version"] == "1.0"
    assert data["status"] == "success"
    assert data["processed_image_path"] == "stub_output/product.jpg"
    assert data["metadata"] == {"test": 123}
    assert data["errors"] == []


def test_rembg_backend_singleton():
    """Verify that RembgBackend behaves as a singleton and exposes predict/load."""
    from vision_studio.models.rembg_backend import RembgBackend, get_rembg_backend

    backend1 = get_rembg_backend()
    backend2 = RembgBackend()
    assert backend1 is backend2
    assert hasattr(backend1, "load")
    assert hasattr(backend1, "predict")

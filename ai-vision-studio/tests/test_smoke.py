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


def test_enhance_phase1_stub_nonexistent_path():
    """Verify enhance returns fake success response even without an image file in Phase 1."""
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

    assert response.status == "success"
    assert response.contract_version == "1.0"
    assert response.processed_image_path is not None
    assert isinstance(response.metadata, dict)
    assert response.errors == []


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


def test_rembg_backend_stub_not_implemented():
    """Verify that RembgBackend raises NotImplementedError in Phase 1 stub."""
    from vision_studio.models.rembg_backend import RembgBackend

    backend = RembgBackend()
    with pytest.raises(NotImplementedError):
        backend.load()
    with pytest.raises(NotImplementedError):
        backend.predict(None)

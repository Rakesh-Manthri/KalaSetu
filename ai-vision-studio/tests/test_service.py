"""Unit and integration tests for Vision Studio FastAPI service."""

from pathlib import Path
import pytest
from fastapi.testclient import TestClient

from vision_studio.service import app
from vision_studio.contracts import EnhanceResponse

FIXTURES_DIR = Path(__file__).parent / "fixtures"


@pytest.fixture
def client():
    """Create FastAPI test client."""
    with TestClient(app) as test_client:
        yield test_client


def test_health_check(client):
    """Test GET /health returns 200 with proper health metadata."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "ai-vision-studio"
    assert data["contract_version"] == "1.0"
    assert data["models_loaded"] is True
    assert data["device"] == "cpu"


def test_enhance_json(client):
    """Test POST /enhance with JSON payload."""
    sample_img = FIXTURES_DIR / "valid_sample.jpg"
    payload = {
        "contract_version": "1.0",
        "image_path": str(sample_img),
        "options": {
            "remove_background": False,
            "correct_lighting": True,
            "quality": "fast",
            "output_size": [500, 500],
        },
    }
    response = client.post("/enhance", json=payload)
    assert response.status_code == 200
    data = response.json()
    validated = EnhanceResponse.model_validate(data)
    assert validated.status in ("success", "partial")
    assert validated.processed_image_path is not None
    assert Path(validated.processed_image_path).exists()


def test_enhance_multipart_upload(client):
    """Test POST /enhance with multipart file upload."""
    sample_img = FIXTURES_DIR / "valid_sample.jpg"
    with open(sample_img, "rb") as f:
        files = {"file": ("test_upload.jpg", f, "image/jpeg")}
        data = {
            "quality": "fast",
            "remove_background": "false",
            "correct_lighting": "true",
            "background_color": "#FFFFFF",
        }
        response = client.post("/enhance", files=files, data=data)

    assert response.status_code == 200
    data = response.json()
    validated = EnhanceResponse.model_validate(data)
    assert validated.status in ("success", "partial")
    assert validated.processed_image_path is not None
    assert Path(validated.processed_image_path).exists()


def test_enhance_invalid_json(client):
    """Test POST /enhance with invalid JSON returns 422/400."""
    response = client.post("/enhance", json={"invalid_field": 123})
    assert response.status_code in (400, 422)


def test_enhance_missing_multipart_file(client):
    """Test POST /enhance multipart with missing file returns 400."""
    response = client.post("/enhance", data={"quality": "fast"})
    assert response.status_code in (400, 422)

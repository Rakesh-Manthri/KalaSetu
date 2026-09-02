import time
from pathlib import Path
import pytest
from pydantic import ValidationError

from vision_studio import EnhanceOptions, EnhanceRequest, EnhanceResponse, VisionStudio
from vision_studio.config import Settings, get_settings
from vision_studio.models.rembg_backend import RembgBackend, get_rembg_backend
from vision_studio.utils.errors import (
    MODEL_LOAD_FAILED,
    STAGE_FAILED,
    TIMEOUT,
    VisionStudioError,
)
from vision_studio.utils.timeout import run_with_timeout


class TestTimeoutHandling:
    """Tests for timeout handling and resilience."""

    def test_run_with_timeout_success(self):
        """Test that a fast function completes and returns value without timing out."""
        def fast_fn(x, y):
            return x + y

        res = run_with_timeout(fast_fn, args=(10, 20), timeout_seconds=1.0)
        assert res == 30

    def test_run_with_timeout_raises_timeout_error(self):
        """Test that a slow function exceeding timeout raises VisionStudioError(code=TIMEOUT)."""
        def slow_fn():
            time.sleep(0.3)
            return "done"

        with pytest.raises(VisionStudioError) as exc_info:
            run_with_timeout(slow_fn, timeout_seconds=0.05, stage="pipeline")

        err = exc_info.value
        assert err.code == TIMEOUT
        assert err.stage == "pipeline"
        assert "timed out after 0.05" in err.message

    def test_run_with_timeout_propagates_internal_exceptions(self):
        """Test that non-timeout exceptions inside target function propagate properly."""
        def failing_fn():
            raise ValueError("custom internal failure")

        with pytest.raises(ValueError, match="custom internal failure"):
            run_with_timeout(failing_fn, timeout_seconds=1.0)

    def test_run_with_timeout_non_positive_timeout_runs_synchronously(self):
        """Test that timeout <= 0 executes synchronously."""
        def sync_fn(a):
            return a * 2

        assert run_with_timeout(sync_fn, args=(5,), timeout_seconds=0) == 10

    def test_enhance_api_timeout_returns_clean_error_response(self, setup_test_fixtures, monkeypatch):
        """Test that VisionStudio.enhance() handles pipeline timeout and returns clean TIMEOUT error response."""
        fixture_path = setup_test_fixtures / "product_textile.jpg"

        # Configure short timeout (0.1s)
        custom_config = Settings(request_timeout_s=0.1)
        studio = VisionStudio(config=custom_config)

        # Monkeypatch validate to sleep 0.25s
        import vision_studio.api as api_mod
        orig_validate = api_mod.validate

        def slow_validate(*args, **kwargs):
            time.sleep(0.25)
            return orig_validate(*args, **kwargs)

        monkeypatch.setattr(api_mod, "validate", slow_validate)

        req = EnhanceRequest(
            image_path=str(fixture_path),
            options=EnhanceOptions(quality="fast"),
        )
        response = studio.enhance(req)

        assert response.status == "error"
        assert response.processed_image_path is None
        assert len(response.errors) == 1
        assert response.errors[0]["code"] == TIMEOUT
        assert response.errors[0]["stage"] == "pipeline"


class TestModelFailureHardening:
    """Tests for model loading failure and graceful error propagation."""

    def test_rembg_session_load_failure_raises_model_load_failed(self, monkeypatch):
        """Test that a failing session creation raises VisionStudioError(code=MODEL_LOAD_FAILED)."""
        backend = get_rembg_backend()

        import vision_studio.models.rembg_backend as rembg_mod

        def failing_new_session(*args, **kwargs):
            raise RuntimeError("Corrupted model weight file or missing provider")

        monkeypatch.setattr(rembg_mod, "new_session", failing_new_session)

        # Clear cached sessions to force reload
        backend._sessions.clear()

        with pytest.raises(VisionStudioError) as exc_info:
            backend._get_session("u2net")

        err = exc_info.value
        assert err.code == MODEL_LOAD_FAILED
        assert err.stage == "bg_removal"
        assert "Corrupted model weight file" in err.message

        # Restore backend state for subsequent tests
        backend._sessions.clear()

    def test_enhance_api_handles_model_load_failure_gracefully(self, setup_test_fixtures, monkeypatch):
        """Test that VisionStudio.enhance() returns clean error response on model load failure."""
        fixture_path = setup_test_fixtures / "product_textile.jpg"
        backend = get_rembg_backend()

        import vision_studio.models.rembg_backend as rembg_mod

        def failing_new_session(*args, **kwargs):
            raise RuntimeError("Model weight loading failed")

        monkeypatch.setattr(rembg_mod, "new_session", failing_new_session)
        backend._sessions.clear()

        studio = VisionStudio()
        req = EnhanceRequest(
            image_path=str(fixture_path),
            options=EnhanceOptions(quality="fast", remove_background=True),
        )

        response = studio.enhance(req)
        assert response.status == "error"
        assert response.processed_image_path is None
        assert len(response.errors) >= 1
        assert response.errors[0]["code"] == MODEL_LOAD_FAILED
        assert response.errors[0]["stage"] == "bg_removal"

        backend._sessions.clear()


class TestPartialSuccessHardening:
    """Tests for partial pipeline success recovery."""

    def test_enhance_returns_partial_status_when_lighting_stage_fails(self, setup_test_fixtures, monkeypatch):
        """Test that when bg_removal succeeds but lighting fails, status is 'partial' with recorded errors."""
        fixture_path = setup_test_fixtures / "product_textile.jpg"

        import vision_studio.api as api_mod

        def failing_correct_lighting(*args, **kwargs):
            raise VisionStudioError(
                code=STAGE_FAILED,
                message="Simulated lighting correction crash",
                stage="lighting",
            )

        monkeypatch.setattr(api_mod, "correct_lighting", failing_correct_lighting)

        studio = VisionStudio()
        req = EnhanceRequest(
            image_path=str(fixture_path),
            options=EnhanceOptions(quality="fast", remove_background=True, correct_lighting=True),
        )

        response = studio.enhance(req)

        assert response.status == "partial"
        assert len(response.errors) >= 1
        assert response.errors[0]["stage"] == "lighting"
        assert response.errors[0]["code"] == STAGE_FAILED
        # Metadata contains successful bg_removal data
        assert response.metadata["bg_removal"] is not None
        assert response.metadata["lighting"] is None


class TestConfigValidation:
    """Tests for Settings configuration and validation."""

    def test_default_settings_values(self):
        """Test default Settings properties."""
        s = Settings()
        assert s.model_dir == "./models"
        assert s.default_quality == "balanced"
        assert s.max_image_mb == 15
        assert s.inference_device == "cpu"
        assert s.request_timeout_s == 20.0
        assert s.output_dir == "./outputs"
        assert s.blur_severe_threshold == 15.0
        assert s.blur_light_threshold == 60.0

    def test_invalid_quality_raises_validation_error(self):
        """Test that invalid quality string raises validation error."""
        with pytest.raises(ValidationError):
            Settings(default_quality="ultra_extreme")

    def test_invalid_max_mb_raises_validation_error(self):
        """Test that negative max_image_mb raises validation error."""
        with pytest.raises(ValidationError):
            Settings(max_image_mb=-5)

    def test_invalid_timeout_raises_validation_error(self):
        """Test that non-positive timeout raises validation error."""
        with pytest.raises(ValidationError):
            Settings(request_timeout_s=0)

    def test_get_settings_cached_singleton(self):
        """Test that get_settings() returns cached instance."""
        s1 = get_settings()
        s2 = get_settings()
        assert s1 is s2

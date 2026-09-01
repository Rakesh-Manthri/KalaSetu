from typing import Any
from .config import Settings
from .contracts import EnhanceOptions, EnhanceRequest, EnhanceResponse
from .pipeline.validate import validate
from .utils.errors import VisionStudioError, make_error
from .utils.logging import get_logger

logger = get_logger(__name__)


class VisionStudio:
    """Main entry point for AI Vision Studio."""

    def __init__(self, config: Settings | None = None) -> None:
        self.config = config or Settings()
        logger.info("Initialized VisionStudio")

    def enhance(self, request: EnhanceRequest | dict[str, Any]) -> EnhanceResponse:
        """Process an image enhancement request.

        Validates the input image (format, dimensions, limits, integrity) and executes
        the enhancement pipeline.
        """
        if isinstance(request, dict):
            req = EnhanceRequest.model_validate(request)
        elif isinstance(request, EnhanceRequest):
            req = request
        else:
            raise TypeError(f"Expected EnhanceRequest or dict, got {type(request).__name__}")

        logger.info("Enhance called for image: %s", req.image_path)

        # Stage 1: Validation & Image I/O
        try:
            image_array, image_metadata = validate(req.image_path)
        except VisionStudioError as e:
            logger.warning("Validation failed for image %s: %s", req.image_path, e.message)
            return EnhanceResponse(
                contract_version="1.0",
                status="error",
                processed_image_path=None,
                metadata={},
                errors=[e.to_dict()],
            )
        except Exception as e:
            logger.error("Unexpected error validating image %s: %s", req.image_path, e, exc_info=True)
            return EnhanceResponse(
                contract_version="1.0",
                status="error",
                processed_image_path=None,
                metadata={},
                errors=[make_error(stage="validate", code="STAGE_FAILED", message=str(e))],
            )

        # Downstream stages will be implemented in subsequent phases
        return EnhanceResponse(
            contract_version="1.0",
            status="success",
            processed_image_path="stub_output/product.jpg",
            metadata={
                "stub": True,
                "phase": 2,
                "options": req.options.model_dump(),
                "original_image_path": req.image_path,
                "image_metadata": image_metadata,
                "message": "Phase 2 validation passed; downstream pipeline stubbed",
            },
            errors=[],
        )


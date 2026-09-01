from typing import Any
from .config import Settings
from .contracts import EnhanceRequest, EnhanceResponse, EnhanceOptions
from .utils.logging import get_logger

logger = get_logger(__name__)


class VisionStudio:
    """Main entry point for AI Vision Studio."""

    def __init__(self, config: Settings | None = None) -> None:
        self.config = config or Settings()
        logger.info("Initialized VisionStudio")

    def enhance(self, request: EnhanceRequest | dict[str, Any]) -> EnhanceResponse:
        """Process an image enhancement request (Phase 1 stub).

        Validates the request schema and returns a fake success EnhanceResponse.
        """
        if isinstance(request, dict):
            req = EnhanceRequest.model_validate(request)
        elif isinstance(request, EnhanceRequest):
            req = request
        else:
            raise TypeError(f"Expected EnhanceRequest or dict, got {type(request).__name__}")

        logger.info("Enhance called for image: %s", req.image_path)

        return EnhanceResponse(
            contract_version="1.0",
            status="success",
            processed_image_path="stub_output/product.jpg",
            metadata={
                "stub": True,
                "phase": 1,
                "options": req.options.model_dump(),
                "original_image_path": req.image_path,
                "message": "Phase 1 stub pipeline executed successfully",
            },
            errors=[],
        )

from typing import Any
from pathlib import Path
import cv2
import numpy as np

from .config import Settings
from .contracts import EnhanceOptions, EnhanceRequest, EnhanceResponse
from .pipeline.validate import validate
from .pipeline.bg_removal import remove_background
from .utils.errors import VisionStudioError, make_error, STAGE_FAILED
from .utils.logging import get_logger
from .utils.image_io import save_image

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
            image_array, image_metadata = validate(
                req.image_path,
                max_mb=self.config.max_image_mb,
                severe_threshold=self.config.blur_severe_threshold,
                light_threshold=self.config.blur_light_threshold,
            )
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

        # Stage 2: Background Removal
        bg_result = None
        errors = []
        try:
            if req.options.remove_background:
                bg_result = remove_background(image_array, req.options.model_dump())
                logger.info("Background removal successful for %s", req.image_path)
            else:
                logger.info("Background removal skipped (disabled in options)")
        except VisionStudioError as e:
            logger.warning("Background removal failed for image %s: %s", req.image_path, e.message)
            errors.append(e.to_dict())
        except Exception as e:
            logger.error("Unexpected error in background removal for %s: %s", req.image_path, e, exc_info=True)
            errors.append(make_error(stage="bg_removal", code=STAGE_FAILED, message=str(e)))

        # Determine overall status
        if errors:
            status = "error"
            processed_path = None
        else:
            status = "partial"  # Later stages (lighting, composition, export) are stubbed
            processed_path = None

        # Save transparent RGBA output if background removal succeeded
        if bg_result is not None:
            try:
                rgba_output = cv2.cvtColor(bg_result.image, cv2.COLOR_BGR2BGRA)
                rgba_output[:, :, 3] = bg_result.mask
                output_dir = Path(self.config.model_dir).parent / "outputs"
                output_dir.mkdir(parents=True, exist_ok=True)
                input_path = Path(req.image_path)
                output_filename = f"{input_path.stem}_nobg.png"
                output_path = output_dir / output_filename
                cv2.imwrite(str(output_path), rgba_output)
                processed_path = str(output_path)
                logger.info("Saved transparent PNG to %s", output_path)
            except Exception as e:
                logger.warning("Failed to save transparent PNG: %s", e)

        return EnhanceResponse(
            contract_version="1.0",
            status=status,
            processed_image_path=processed_path,
            metadata={
                "phase": 3,
                "options": req.options.model_dump(),
                "original_image_path": req.image_path,
                "image_metadata": image_metadata,
                "bg_removal": bg_result.metadata if bg_result else None,
            },
            errors=errors,
        )
from typing import Any
from pathlib import Path
import time
import cv2
import numpy as np

from .config import Settings
from .contracts import EnhanceOptions, EnhanceRequest, EnhanceResponse
from .pipeline.validate import validate
from .pipeline.bg_removal import remove_background
from .pipeline.lighting import correct_lighting
from .pipeline.composition import compose
from .pipeline.export import export
from .utils.errors import VisionStudioError, make_error, STAGE_FAILED
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
        the complete end-to-end enhancement pipeline:
        validate -> bg_removal -> lighting -> composition -> export.
        """
        pipeline_start = time.perf_counter()

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

        errors: list[dict[str, Any]] = []

        # Stage 2: Background Removal
        bg_result = None
        if req.options.remove_background:
            try:
                bg_result = remove_background(image_array, req.options.model_dump())
                logger.info("Background removal successful for %s", req.image_path)
            except VisionStudioError as e:
                logger.warning("Background removal failed for image %s: %s", req.image_path, e.message)
                errors.append(e.to_dict())
            except Exception as e:
                logger.error("Unexpected error in background removal for %s: %s", req.image_path, e, exc_info=True)
                errors.append(make_error(stage="bg_removal", code=STAGE_FAILED, message=str(e)))
        else:
            logger.info("Background removal skipped (disabled in options)")

        # Prepare inputs for downstream stages
        current_image = bg_result.image if bg_result is not None else image_array
        current_mask = bg_result.mask if bg_result is not None else None
        current_bbox = bg_result.bbox if bg_result is not None else None

        # Stage 3: Lighting Correction
        lighting_result = None
        if not errors and req.options.correct_lighting:
            try:
                lighting_result = correct_lighting(
                    current_image,
                    mask=current_mask,
                    cfg=req.options.model_dump(),
                    raw_image_bgr=image_array,
                )
                current_image = lighting_result.image
                logger.info("Lighting correction successful for %s", req.image_path)
            except VisionStudioError as e:
                logger.warning("Lighting correction failed for image %s: %s", req.image_path, e.message)
                errors.append(e.to_dict())
            except Exception as e:
                logger.error("Unexpected error in lighting correction for %s: %s", req.image_path, e, exc_info=True)
                errors.append(make_error(stage="lighting", code=STAGE_FAILED, message=str(e)))
        elif not req.options.correct_lighting:
            logger.info("Lighting correction skipped (disabled in options)")

        # Stage 4: Composition & Canvas Formatting
        comp_result = None
        if not errors:
            try:
                comp_result = compose(
                    foreground_bgr=current_image,
                    mask=current_mask,
                    bbox=current_bbox,
                    cfg=req.options,
                )
                logger.info("Composition successful for %s", req.image_path)
            except VisionStudioError as e:
                logger.warning("Composition failed for image %s: %s", req.image_path, e.message)
                errors.append(e.to_dict())
            except Exception as e:
                logger.error("Unexpected error in composition for %s: %s", req.image_path, e, exc_info=True)
                errors.append(make_error(stage="composition", code=STAGE_FAILED, message=str(e)))

        # Stage 5: Export & Montage Generation
        export_result = None
        output_dir = Path(self.config.model_dir).parent / "outputs"
        output_dir.mkdir(parents=True, exist_ok=True)
        input_stem = Path(req.image_path).stem

        # Save transparent RGBA cutout as companion artifact if background removal was performed
        if bg_result is not None and not errors:
            try:
                rgba_output = cv2.cvtColor(current_image, cv2.COLOR_BGR2BGRA)
                rgba_output[:, :, 3] = bg_result.mask
                transparent_path = output_dir / f"{input_stem}_nobg.png"
                cv2.imwrite(str(transparent_path), rgba_output)
                logger.info("Saved transparent PNG to %s", transparent_path)
            except Exception as e:
                logger.warning("Failed to save companion transparent PNG: %s", e)

        if not errors and comp_result is not None:
            try:
                export_result = export(
                    final_bgr=comp_result.image,
                    out_dir=output_dir,
                    name=input_stem,
                    original_bgr=image_array,
                    cfg=req.options,
                )
                logger.info("Export successful for %s -> %s", req.image_path, export_result.image_path)
            except VisionStudioError as e:
                logger.warning("Export failed for image %s: %s", req.image_path, e.message)
                errors.append(e.to_dict())
            except Exception as e:
                logger.error("Unexpected error in export for %s: %s", req.image_path, e, exc_info=True)
                errors.append(make_error(stage="export", code=STAGE_FAILED, message=str(e)))

        total_duration_ms = round((time.perf_counter() - pipeline_start) * 1000, 2)

        # Determine overall response status
        if not errors and export_result is not None:
            status = "success"
            processed_path = export_result.image_path
        elif errors and (bg_result is not None or lighting_result is not None or comp_result is not None):
            status = "partial"
            processed_path = None
        else:
            status = "error" if errors else "success"
            processed_path = export_result.image_path if export_result else None

        processed_dims = (
            [comp_result.image.shape[1], comp_result.image.shape[0]]
            if comp_result is not None
            else image_metadata["norm_dims"]
        )

        metadata: dict[str, Any] = {
            "duration_ms": total_duration_ms,
            "background_removed": req.options.remove_background and (bg_result is not None),
            "orig_dims": image_metadata["orig_dims"],
            "processed_dims": processed_dims,
            "quality": req.options.quality,
            "options": req.options.model_dump(),
            "original_image_path": req.image_path,
            "image_metadata": image_metadata,
            "stages": {
                "validate": image_metadata,
                "bg_removal": bg_result.metadata if bg_result else None,
                "lighting": lighting_result.metadata if lighting_result else None,
                "composition": comp_result.metadata if comp_result else None,
                "export": export_result.metadata if export_result else None,
            },
            "bg_removal": bg_result.metadata if bg_result else None,
            "lighting": lighting_result.metadata if lighting_result else None,
            "composition": comp_result.metadata if comp_result else None,
            "export": export_result.metadata if export_result else None,
            "montage_path": export_result.montage_path if export_result else None,
        }

        return EnhanceResponse(
            contract_version="1.0",
            status=status,
            processed_image_path=processed_path,
            metadata=metadata,
            errors=errors,
        )
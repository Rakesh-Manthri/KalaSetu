import time
from dataclasses import dataclass
from typing import Any
import cv2
import numpy as np

from vision_studio.models.rembg_backend import get_rembg_backend
from vision_studio.utils.errors import VisionStudioError, STAGE_FAILED
from vision_studio.utils.logging import get_logger

logger = get_logger(__name__)


@dataclass
class BgRemovalResult:
    """Result of background removal pipeline stage."""

    image: np.ndarray
    mask: np.ndarray
    bbox: tuple[int, int, int, int]
    metadata: dict[str, Any]


def remove_background(
    image_bgr: np.ndarray,
    cfg: Any = None,
) -> BgRemovalResult:
    """Remove background from a validated BGR image.

    Args:
        image_bgr: Normalized BGR uint8 ndarray from validation stage (max long edge <= 2000).
        cfg: Configuration object or dict with 'quality' key ('fast', 'balanced', 'high').

    Returns:
        BgRemovalResult with:
            - image: Foreground BGR ndarray (same HxW as input)
            - mask: Alpha mask uint8 0-255 (same HxW as input)
            - bbox: Subject bounding box (x, y, w, h) from mask bounding rect
            - metadata: Dict with quality, model, duration_ms, input_dims

    Raises:
        VisionStudioError: If mask is empty/near-empty (code=EMPTY_MASK, stage=bg_removal)
        VisionStudioError: If model inference fails (code=STAGE_FAILED, stage=bg_removal)
    """
    quality = "balanced"
    if cfg is not None:
        if isinstance(cfg, dict):
            quality = cfg.get("quality", "balanced")
        else:
            quality = getattr(cfg, "quality", "balanced")

    backend = get_rembg_backend()

    start_time = time.perf_counter()
    try:
        foreground_bgr, alpha_mask = backend.predict(image_bgr, quality=quality)
    except Exception as e:
        logger.error("Background removal inference failed: %s", e)
        raise VisionStudioError(
            code=STAGE_FAILED,
            message=f"Background removal inference failed: {e}",
            stage="bg_removal",
        ) from e
    duration_ms = (time.perf_counter() - start_time) * 1000

    h, w = alpha_mask.shape[:2]

    # Validate that mask is non-empty
    non_zero = cv2.findNonZero(alpha_mask)
    if non_zero is None or len(non_zero) == 0:
        logger.warning("Empty mask detected after background removal")
        raise VisionStudioError(
            code="EMPTY_MASK",
            message="Background removal produced an empty mask - no foreground subject detected",
            stage="bg_removal",
        )

    # Compute bounding box (x, y, w, h)
    x, y, bw, bh = cv2.boundingRect(non_zero)
    bbox = (int(x), int(y), int(bw), int(bh))

    config = backend._quality_config.get(quality, backend._quality_config["balanced"])
    model_name = config["model"]

    metadata = {
        "quality": quality,
        "model": model_name,
        "duration_ms": round(duration_ms, 2),
        "input_dims": (w, h),
    }

    logger.info(
        "Background removal completed: quality=%s, model=%s, duration_ms=%.2f, bbox=(%d,%d,%d,%d)",
        quality,
        model_name,
        duration_ms,
        x,
        y,
        bw,
        bh,
    )

    return BgRemovalResult(
        image=foreground_bgr,
        mask=alpha_mask,
        bbox=bbox,
        metadata=metadata,
    )
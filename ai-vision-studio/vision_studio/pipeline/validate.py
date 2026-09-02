import time
from pathlib import Path
from typing import Any
import numpy as np

from ..utils.image_io import load_image
from .blur import BLUR_LIGHT_THRESHOLD, BLUR_SEVERE_THRESHOLD, process_blur


def validate(
    image_path: str | Path,
    max_mb: float = 15.0,
    max_edge: int = 2000,
    severe_threshold: float = BLUR_SEVERE_THRESHOLD,
    light_threshold: float = BLUR_LIGHT_THRESHOLD,
) -> tuple[np.ndarray, dict[str, Any]]:
    """Validate input image path, format, dimensions, integrity, limits, and sharpness.

    Ensures the image is loaded, verified, EXIF transposed, downscaled (long edge <= max_edge),
    converted to a normalized uint8 BGR ndarray, and evaluated for blur quality.
    Lightly blurry images receive OpenCV unsharp masking before return.
    Severely blurry images raise VisionStudioError(code=IMAGE_TOO_BLURRY).

    Returns:
        tuple[np.ndarray, dict]: (normalized_or_sharpened_bgr_ndarray, metadata_dict)

    Raises:
        VisionStudioError: If validation fails with a specific error code
            (FILE_NOT_FOUND, INVALID_IMAGE, UNSUPPORTED_FORMAT, IMAGE_TOO_LARGE, IMAGE_TOO_BLURRY).
    """
    t0 = time.perf_counter()
    image_bgr, metadata = load_image(path=image_path, max_mb=max_mb)
    processed_bgr, blur_meta = process_blur(
        image_bgr,
        severe_threshold=severe_threshold,
        light_threshold=light_threshold,
    )
    metadata.update(blur_meta)
    metadata["duration_ms"] = round((time.perf_counter() - t0) * 1000, 2)
    return processed_bgr, metadata


# Backward compatibility alias
validate_image = validate

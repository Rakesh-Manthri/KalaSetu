from pathlib import Path
from typing import Any
import numpy as np

from ..utils.image_io import load_image


def validate(
    image_path: str | Path,
    max_mb: float = 15.0,
    max_edge: int = 2000,
) -> tuple[np.ndarray, dict[str, Any]]:
    """Validate input image path, format, dimensions, integrity, and limits.

    Ensures the image is loaded, verified, EXIF transposed, downscaled (long edge <= max_edge),
    and converted to a normalized uint8 BGR ndarray.

    Returns:
        tuple[np.ndarray, dict]: (normalized_bgr_ndarray, metadata_dict)

    Raises:
        VisionStudioError: If validation fails with a specific error code
            (FILE_NOT_FOUND, INVALID_IMAGE, UNSUPPORTED_FORMAT, IMAGE_TOO_LARGE).
    """
    return load_image(path=image_path, max_mb=max_mb)


# Backward compatibility alias
validate_image = validate


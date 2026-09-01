import os
from pathlib import Path
from typing import Any
import cv2
import numpy as np
from PIL import Image, ImageOps, UnidentifiedImageError

from .errors import (
    FILE_NOT_FOUND,
    IMAGE_TOO_LARGE,
    INVALID_IMAGE,
    STAGE_FAILED,
    UNSUPPORTED_FORMAT,
    VisionStudioError,
)
from .logging import get_logger

logger = get_logger(__name__)

# Standard allowed formats
SUPPORTED_FORMATS = {"JPEG", "JPG", "PNG", "WEBP"}


def downscale_long_edge(arr: np.ndarray, max_edge: int = 2000) -> np.ndarray:
    """Downscale an image array so its longest edge is at most `max_edge` pixels.

    Preserves aspect ratio and uses cv2.INTER_AREA for clean downsampling.
    """
    h, w = arr.shape[:2]
    long_edge = max(h, w)
    if long_edge > max_edge:
        scale = max_edge / float(long_edge)
        new_w = max(1, int(round(w * scale)))
        new_h = max(1, int(round(h * scale)))
        logger.info(
            "Downscaling image from (%d, %d) to (%d, %d) [max_edge=%d]",
            w,
            h,
            new_w,
            new_h,
            max_edge,
        )
        return cv2.resize(arr, (new_w, new_h), interpolation=cv2.INTER_AREA)
    return arr


def load_image(path: str | Path, max_mb: float = 15.0) -> tuple[np.ndarray, dict[str, Any]]:
    """Load, validate, and normalize an input image.

    Performs:
    1. Existence check -> FILE_NOT_FOUND
    2. File size check -> IMAGE_TOO_LARGE
    3. PIL opening and integrity validation -> INVALID_IMAGE
    4. Supported format check -> UNSUPPORTED_FORMAT (handles HEIC specifically)
    5. EXIF orientation correction via PIL ImageOps.exif_transpose
    6. Transparency detection
    7. Conversion to uint8 BGR OpenCV ndarray
    8. Downscaling to max long edge of 2000px

    Returns:
        tuple[np.ndarray, dict]: (normalized BGR ndarray, metadata dict)
    """
    file_path = Path(path)

    # 1. Existence check
    if not file_path.exists() or not file_path.is_file():
        raise VisionStudioError(
            code=FILE_NOT_FOUND,
            message=f"Image file not found: {path}",
            stage="validate",
        )

    # 2. File size check
    max_bytes = max_mb * 1024 * 1024
    file_size = os.path.getsize(file_path)
    if file_size > max_bytes:
        raise VisionStudioError(
            code=IMAGE_TOO_LARGE,
            message=f"Image file size ({file_size / (1024 * 1024):.2f} MB) exceeds limit of {max_mb} MB",
            stage="validate",
        )

    # 3. Open image with PIL & integrity check
    try:
        pil_img = Image.open(file_path)
        # Attempt to load image data to catch corrupt/truncated files
        pil_img.load()
    except UnidentifiedImageError as e:
        # Check if file has an unsupported extension like .txt, .pdf, or .heic
        ext = file_path.suffix.lower().lstrip(".")
        if ext in ("heic", "heif"):
            raise VisionStudioError(
                code=UNSUPPORTED_FORMAT,
                message="HEIC/HEIF format is not supported in the current environment. Please convert to JPEG or PNG.",
                stage="validate",
            ) from e
        raise VisionStudioError(
            code=INVALID_IMAGE if ext in ("jpg", "jpeg", "png", "webp") else UNSUPPORTED_FORMAT,
            message=f"Cannot identify or decode image file '{path}': {e}",
            stage="validate",
        ) from e
    except Exception as e:
        raise VisionStudioError(
            code=INVALID_IMAGE,
            message=f"Corrupt or unreadable image file '{path}': {e}",
            stage="validate",
        ) from e

    # 4. Format validation
    raw_fmt = (pil_img.format or file_path.suffix.lstrip(".")).upper()
    if raw_fmt in ("HEIC", "HEIF"):
        # If opened successfully (pillow-heif installed), allowed; else error
        pass
    elif raw_fmt not in SUPPORTED_FORMATS:
        raise VisionStudioError(
            code=UNSUPPORTED_FORMAT,
            message=f"Unsupported image format: '{raw_fmt}'. Allowed formats are JPEG, PNG, WEBP.",
            stage="validate",
        )

    # 5. Handle EXIF orientation
    try:
        transposed_img = ImageOps.exif_transpose(pil_img)
        if transposed_img is not None:
            pil_img = transposed_img
    except Exception as e:
        logger.warning("Failed to apply EXIF transpose to %s: %s", path, e)

    # 6. Check transparency
    has_alpha = pil_img.mode in ("RGBA", "LA", "PA") or ("transparency" in pil_img.info)

    # 7. Convert to RGB and then BGR OpenCV ndarray
    if pil_img.mode != "RGB":
        pil_img = pil_img.convert("RGB")

    rgb_array = np.array(pil_img, dtype=np.uint8)
    bgr_array = cv2.cvtColor(rgb_array, cv2.COLOR_RGB2BGR)

    orig_h, orig_w = bgr_array.shape[:2]
    orig_dims = (orig_w, orig_h)

    # 8. Downscale if long edge > 2000px
    norm_array = downscale_long_edge(bgr_array, max_edge=2000)
    norm_h, norm_w = norm_array.shape[:2]
    norm_dims = (norm_w, norm_h)

    metadata: dict[str, Any] = {
        "orig_dims": orig_dims,
        "norm_dims": norm_dims,
        "format": raw_fmt.lower(),
        "has_alpha": has_alpha,
    }

    return norm_array, metadata


def save_image(arr: np.ndarray, path: str | Path) -> str:
    """Save an OpenCV BGR image array to disk.

    Creates parent directories if necessary.
    """
    out_path = Path(path)
    try:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        success = cv2.imwrite(str(out_path), arr)
        if not success:
            raise VisionStudioError(
                code=STAGE_FAILED,
                message=f"cv2.imwrite failed to write image to {out_path}",
                stage="export",
            )
        return str(out_path)
    except VisionStudioError:
        raise
    except Exception as e:
        raise VisionStudioError(
            code=STAGE_FAILED,
            message=f"Failed to save image to '{out_path}': {e}",
            stage="export",
        ) from e

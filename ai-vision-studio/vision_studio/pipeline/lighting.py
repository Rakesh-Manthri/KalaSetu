from dataclasses import dataclass
from typing import Any
import time
import cv2
import numpy as np

from ..utils.logging import get_logger

logger = get_logger(__name__)

# Defaults & guard clamps
MIN_GAIN = 0.6
MAX_GAIN = 1.8
MIN_GAMMA = 0.5
MAX_GAMMA = 2.0
TARGET_LUMINANCE = 128.0
CLAHE_CLIP_LIMIT = 2.0
CLAHE_TILE_GRID_SIZE = (8, 8)
# White balance blend factor: 0.30 applies gentle ambient cast correction while preserving authentic artisan craft hues
WB_CORRECTION_STRENGTH = 0.30


@dataclass
class LightingResult:
    """Result of lighting correction stage."""
    image: np.ndarray             # np.ndarray, dtype=uint8, shape=(H, W, 3), BGR format
    metadata: dict[str, Any]      # metadata dictionary containing gains, gamma, luminances, duration


def compute_masked_luminance(bgr: np.ndarray, mask_bool: np.ndarray) -> float:
    """Compute mean perceived luminance (ITU-R BT.601) on masked pixels."""
    pixels = bgr[mask_bool]
    if len(pixels) == 0:
        return 0.0
    # Luminance Y = 0.114 * B + 0.587 * G + 0.299 * R
    lum = (
        0.114 * pixels[:, 0].astype(np.float32)
        + 0.587 * pixels[:, 1].astype(np.float32)
        + 0.299 * pixels[:, 2].astype(np.float32)
    )
    return float(np.mean(lum))


def correct_lighting(
    image_bgr: np.ndarray,
    mask: np.ndarray | None = None,
    cfg: Any = None,
    raw_image_bgr: np.ndarray | None = None,
) -> LightingResult:
    """Apply classical computer vision lighting, white balance, and contrast corrections.

    Works on foreground pixels defined by the mask, leaving background pixels untouched.
    If mask is None or contains no foreground pixels, falls back to correcting the entire image.

    Pipeline:
        1. Gentle white balance via Gray-World assumption on masked foreground with chromaticity preservation.
        2. Auto-gamma adjustment based on masked mean luminance toward target mid-gray.
        3. CLAHE on LAB L-channel to lift shadow details and improve local contrast.
        4. Masked blend to guarantee background pixels (mask == 0) remain bitwise unchanged.

    Args:
        image_bgr: Input BGR image (uint8, shape HxWx3).
        mask: Optional single-channel alpha mask (uint8, shape HxW, values 0-255).
        cfg: Optional configuration dictionary or object.
        raw_image_bgr: Optional raw unsegmented input image.

    Returns:
        LightingResult containing corrected BGR image and execution metadata.
    """
    start_time = time.perf_counter()

    if not isinstance(image_bgr, np.ndarray) or image_bgr.ndim != 3 or image_bgr.shape[2] != 3:
        raise ValueError("image_bgr must be a 3-channel BGR numpy array")

    h, w, _ = image_bgr.shape

    # Determine foreground mask boolean
    if mask is not None and np.count_nonzero(mask > 0) > 0:
        if mask.shape[:2] != (h, w):
            mask_resized = cv2.resize(mask, (w, h), interpolation=cv2.INTER_NEAREST)
            mask_bool = mask_resized > 0
        else:
            mask_bool = mask > 0
        is_fallback = False
    else:
        mask_bool = np.ones((h, w), dtype=bool)
        is_fallback = True

    fg_pixels = image_bgr[mask_bool].astype(np.float32)

    # Initial luminance before correction
    mean_lum_before = compute_masked_luminance(image_bgr, mask_bool)

    # 1. White Balance via Gray-World on masked foreground
    mean_b = float(np.mean(fg_pixels[:, 0]))
    mean_g = float(np.mean(fg_pixels[:, 1]))
    mean_r = float(np.mean(fg_pixels[:, 2]))
    mean_gray = (mean_b + mean_g + mean_r) / 3.0

    if mean_b > 1e-3 and mean_g > 1e-3 and mean_r > 1e-3:
        raw_gain_b = mean_gray / mean_b
        raw_gain_g = mean_gray / mean_g
        raw_gain_r = mean_gray / mean_r
    else:
        raw_gain_b = raw_gain_g = raw_gain_r = 1.0

    raw_gain_b = float(np.clip(raw_gain_b, MIN_GAIN, MAX_GAIN))
    raw_gain_g = float(np.clip(raw_gain_g, MIN_GAIN, MAX_GAIN))
    raw_gain_r = float(np.clip(raw_gain_r, MIN_GAIN, MAX_GAIN))

    # Apply gentle white balance correction strength to preserve inherent craft colors
    gain_b = float(1.0 + (raw_gain_b - 1.0) * WB_CORRECTION_STRENGTH)
    gain_g = float(1.0 + (raw_gain_g - 1.0) * WB_CORRECTION_STRENGTH)
    gain_r = float(1.0 + (raw_gain_r - 1.0) * WB_CORRECTION_STRENGTH)

    # Apply WB gains across the image
    wb_img = image_bgr.astype(np.float32)
    wb_img[:, :, 0] *= gain_b
    wb_img[:, :, 1] *= gain_g
    wb_img[:, :, 2] *= gain_r
    wb_img = np.clip(wb_img, 0, 255).astype(np.uint8)

    # 2. Auto-Gamma Correction
    wb_lum = compute_masked_luminance(wb_img, mask_bool)
    norm_lum = max(min(wb_lum / 255.0, 0.99), 0.01)
    norm_target = TARGET_LUMINANCE / 255.0

    # Auto-gamma formula: (norm_lum) ^ gamma = norm_target -> gamma = ln(norm_target) / ln(norm_lum)
    raw_gamma = float(np.log(norm_target) / np.log(norm_lum))
    gamma = float(np.clip(raw_gamma, MIN_GAMMA, MAX_GAMMA))

    # Build LUT for gamma correction
    gamma_lut = np.array(
        [np.clip(pow(i / 255.0, gamma) * 255.0, 0, 255) for i in range(256)],
        dtype=np.uint8,
    )
    gamma_img = cv2.LUT(wb_img, gamma_lut)

    # 3. CLAHE on LAB L-channel (preserves chromaticity in A & B channels)
    lab_img = cv2.cvtColor(gamma_img, cv2.COLOR_BGR2LAB)
    l_chan, a_chan, b_chan = cv2.split(lab_img)

    clahe = cv2.createCLAHE(
        clipLimit=CLAHE_CLIP_LIMIT,
        tileGridSize=CLAHE_TILE_GRID_SIZE,
    )
    l_clahe = clahe.apply(l_chan)
    lab_clahe = cv2.merge([l_clahe, a_chan, b_chan])
    corrected_bgr = cv2.cvtColor(lab_clahe, cv2.COLOR_LAB2BGR)

    # 4. Blend corrected foreground back onto original foreground using mask
    if is_fallback:
        final_image = corrected_bgr
    else:
        # Guarantee background pixels (mask == 0) remain 100% bitwise identical to input image_bgr
        final_image = image_bgr.copy()
        final_image[mask_bool] = corrected_bgr[mask_bool]

    mean_lum_after = compute_masked_luminance(final_image, mask_bool)
    duration_ms = (time.perf_counter() - start_time) * 1000.0

    metadata = {
        "white_balance_gains": [round(gain_r, 4), round(gain_g, 4), round(gain_b, 4)],  # [R, G, B] order
        "gamma_applied": round(gamma, 4),
        "mean_luminance_before": round(mean_lum_before, 2),
        "mean_luminance_after": round(mean_lum_after, 2),
        "fallback_full_image": is_fallback,
        "duration_ms": round(duration_ms, 2),
    }

    return LightingResult(image=final_image, metadata=metadata)

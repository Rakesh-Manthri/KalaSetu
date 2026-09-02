from dataclasses import dataclass
from typing import Any
import time
import cv2
import numpy as np

from ..utils.logging import get_logger

logger = get_logger(__name__)


@dataclass
class CompositionResult:
    """Output container for the composition stage."""
    image: np.ndarray  # (H, W, 3) BGR uint8
    metadata: dict[str, Any]


def hex_to_bgr(hex_str: str) -> tuple[int, int, int]:
    """Convert hex color string (e.g. '#FFFFFF' or '#FFF') to BGR tuple."""
    if not isinstance(hex_str, str):
        return (255, 255, 255)
    clean = hex_str.strip().lstrip("#")
    if len(clean) == 3:
        clean = "".join(c * 2 for c in clean)
    if len(clean) != 6:
        return (255, 255, 255)
    try:
        r = int(clean[0:2], 16)
        g = int(clean[2:4], 16)
        b = int(clean[4:6], 16)
        return (b, g, r)
    except ValueError:
        return (255, 255, 255)


def compose(
    foreground_bgr: np.ndarray,
    mask: np.ndarray | None,
    bbox: tuple[int, int, int, int] | None = None,
    cfg: Any = None,
) -> CompositionResult:
    """Center, pad, resize, and place product foreground onto standard e-commerce canvas.

    Args:
        foreground_bgr: BGR image array (H, W, 3), uint8.
        mask: Grayscale alpha mask (H, W), uint8 in [0, 255].
        bbox: Optional subject bounding box (x, y, w, h). If None, calculated from mask.
        cfg: Configuration dictionary or EnhanceOptions instance.

    Returns:
        CompositionResult containing composite BGR image and execution metadata.
    """
    start_time = time.perf_counter()

    # Extract options
    if cfg is None:
        cfg_dict = {}
    elif isinstance(cfg, dict):
        cfg_dict = cfg
    elif hasattr(cfg, "model_dump"):
        cfg_dict = cfg.model_dump()
    elif hasattr(cfg, "__dict__"):
        cfg_dict = cfg.__dict__
    else:
        cfg_dict = {}

    output_size = cfg_dict.get("output_size", (1000, 1000))
    if not isinstance(output_size, (tuple, list)) or len(output_size) != 2:
        output_size = (1000, 1000)
    canvas_w, canvas_h = int(output_size[0]), int(output_size[1])

    bg_color_hex = cfg_dict.get("background_color", "#FFFFFF")
    bg_bgr = hex_to_bgr(bg_color_hex)
    quality = cfg_dict.get("quality", "balanced")
    margin_pct = cfg_dict.get("margin_pct", 0.08)

    img_h, img_w = foreground_bgr.shape[:2]

    # Handle mask fallback
    if mask is None:
        mask = np.full((img_h, img_w), 255, dtype=np.uint8)

    # Determine bounding box
    if bbox is None or len(bbox) != 4 or bbox[2] <= 0 or bbox[3] <= 0:
        non_zero = cv2.findNonZero(mask)
        if non_zero is not None and len(non_zero) > 0:
            bx, by, bw, bh = cv2.boundingRect(non_zero)
        else:
            bx, by, bw, bh = 0, 0, img_w, img_h
    else:
        bx, by, bw, bh = bbox

    # Clamp bbox within image boundaries
    bx = max(0, min(bx, img_w - 1))
    by = max(0, min(by, img_h - 1))
    bw = max(1, min(bw, img_w - bx))
    bh = max(1, min(bh, img_h - by))

    # Crop subject foreground and mask
    cropped_fg = foreground_bgr[by : by + bh, bx : bx + bw]
    cropped_mask = mask[by : by + bh, bx : bx + bw]

    # Calculate target box preserving 8% margin
    margin_w = int(round(margin_pct * canvas_w))
    margin_h = int(round(margin_pct * canvas_h))
    avail_w = max(1, canvas_w - 2 * margin_w)
    avail_h = max(1, canvas_h - 2 * margin_h)

    # Calculate scale factor to fit within available area preserving aspect ratio
    scale = min(avail_w / bw, avail_h / bh)
    new_w = max(1, int(round(bw * scale)))
    new_h = max(1, int(round(bh * scale)))

    # Resize cropped subject and mask
    interp_fg = cv2.INTER_AREA if scale < 1.0 else cv2.INTER_LANCZOS4
    interp_mask = cv2.INTER_AREA if scale < 1.0 else cv2.INTER_LINEAR

    resized_fg = cv2.resize(cropped_fg, (new_w, new_h), interpolation=interp_fg)
    resized_mask = cv2.resize(cropped_mask, (new_w, new_h), interpolation=interp_mask)

    # Calculate centering offsets
    offset_x = (canvas_w - new_w) // 2
    offset_y = (canvas_h - new_h) // 2

    # Initialize canvas with background color
    canvas = np.full((canvas_h, canvas_w, 3), bg_bgr, dtype=np.uint8)

    # Optional subtle drop shadow (skipped for 'fast' quality mode)
    shadow_applied = False
    if quality != "fast":
        try:
            shadow_applied = True
            # Vertical drop offset ~1.5% of canvas height
            dy = max(3, int(round(0.015 * canvas_h)))
            sy = min(canvas_h - new_h, offset_y + dy)
            sx = offset_x

            # Create full canvas shadow mask
            shadow_plane = np.zeros((canvas_h, canvas_w), dtype=np.float32)
            shadow_plane[sy : sy + new_h, sx : sx + new_w] = resized_mask.astype(np.float32) / 255.0

            # Blur shadow mask for soft dispersion
            ksize = int(round(0.025 * canvas_h)) | 1
            blurred_shadow = cv2.GaussianBlur(shadow_plane, (ksize, ksize), sigmaX=ksize / 3.0)

            # Subtle opacity ~12-15%
            shadow_opacity = 0.12
            shadow_factor = (blurred_shadow * shadow_opacity)[..., None]

            # Multiply canvas towards dark neutral tone
            canvas_float = canvas.astype(np.float32)
            canvas_float = canvas_float * (1.0 - shadow_factor)
            canvas = np.clip(canvas_float, 0, 255).astype(np.uint8)
        except Exception as e:
            logger.warning("Failed to render soft shadow: %s", e)

    # Antialias subject mask edges via small Gaussian blur (~1px)
    blurred_mask = cv2.GaussianBlur(resized_mask, (3, 3), sigmaX=0.8)
    alpha = (blurred_mask.astype(np.float32) / 255.0)[..., None]

    # Composite foreground over canvas
    roi = canvas[offset_y : offset_y + new_h, offset_x : offset_x + new_w].astype(np.float32)
    blended_roi = resized_fg.astype(np.float32) * alpha + roi * (1.0 - alpha)
    canvas[offset_y : offset_y + new_h, offset_x : offset_x + new_w] = np.clip(blended_roi, 0, 255).astype(np.uint8)

    duration_ms = round((time.perf_counter() - start_time) * 1000, 2)

    metadata = {
        "output_size": [canvas_w, canvas_h],
        "background_color": bg_color_hex,
        "margin_pct": margin_pct,
        "subject_dims": [new_w, new_h],
        "offsets": [offset_x, offset_y],
        "shadow_applied": shadow_applied,
        "duration_ms": duration_ms,
    }

    return CompositionResult(image=canvas, metadata=metadata)


def compose_product(image: Any, cfg: Any = None) -> tuple[Any, dict]:
    """Compatibility wrapper for Phase 1 stub."""
    res = compose(image, mask=None, cfg=cfg)
    return res.image, res.metadata

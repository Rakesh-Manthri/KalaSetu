from dataclasses import dataclass
from pathlib import Path
from typing import Any
import time
import cv2
import numpy as np

from ..utils.logging import get_logger

logger = get_logger(__name__)


@dataclass
class ExportResult:
    """Output container for the export stage."""
    image_path: str
    montage_path: str | None
    metadata: dict[str, Any]


def create_before_after_montage(
    original_bgr: np.ndarray,
    final_bgr: np.ndarray,
    banner_height: int = 50,
) -> np.ndarray:
    """Create a side-by-side Before/After comparison montage.

    Args:
        original_bgr: The original raw input image (BGR, uint8).
        final_bgr: The final e-commerce standardized composite image (BGR, uint8).
        banner_height: Height in pixels for the header banner.

    Returns:
        Montage image array (BGR, uint8).
    """
    final_h, final_w = final_bgr.shape[:2]
    orig_h, orig_w = original_bgr.shape[:2]

    # Fit original image to match the final image canvas dimensions (letterboxed/centered on neutral dark background)
    panel_left = np.full((final_h, final_w, 3), 245, dtype=np.uint8)  # soft neutral background
    scale_orig = min(final_w / orig_w, final_h / orig_h)
    new_orig_w = max(1, int(round(orig_w * scale_orig)))
    new_orig_h = max(1, int(round(orig_h * scale_orig)))

    interp = cv2.INTER_AREA if scale_orig < 1.0 else cv2.INTER_LANCZOS4
    resized_orig = cv2.resize(original_bgr, (new_orig_w, new_orig_h), interpolation=interp)

    off_x = (final_w - new_orig_w) // 2
    off_y = (final_h - new_orig_h) // 2
    panel_left[off_y : off_y + new_orig_h, off_x : off_x + new_orig_w] = resized_orig

    panel_right = final_bgr.copy()

    # Create full canvas including top header banner
    total_w = final_w * 2 + 2  # 2px divider
    total_h = final_h + banner_height
    montage = np.zeros((total_h, total_w, 3), dtype=np.uint8)

    # Dark slate header banner (BGR: [30, 25, 20])
    montage[0:banner_height, :] = [30, 25, 20]

    # Place left and right panels
    montage[banner_height:, :final_w] = panel_left
    # 2px subtle divider line
    montage[banner_height:, final_w : final_w + 2] = [200, 200, 200]
    montage[banner_height:, final_w + 2 :] = panel_right

    # Render header typography
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.75 * (final_w / 1000.0)
    thickness = max(1, int(round(1.8 * (final_w / 1000.0))))

    # Left header: BEFORE
    label_before = "BEFORE: Raw Artisan Photo"
    text_size_b, _ = cv2.getTextSize(label_before, font, font_scale, thickness)
    text_x_b = (final_w - text_size_b[0]) // 2
    text_y_b = (banner_height + text_size_b[1]) // 2
    cv2.putText(
        montage,
        label_before,
        (text_x_b, text_y_b),
        font,
        font_scale,
        (180, 180, 180),
        thickness,
        cv2.LINE_AA,
    )

    # Right header: AFTER
    label_after = "AFTER: KalaSetu AI Studio"
    text_size_a, _ = cv2.getTextSize(label_after, font, font_scale, thickness)
    text_x_a = final_w + 2 + (final_w - text_size_a[0]) // 2
    text_y_a = (banner_height + text_size_a[1]) // 2
    cv2.putText(
        montage,
        label_after,
        (text_x_a, text_y_a),
        font,
        font_scale,
        (100, 230, 130),  # vibrant light green accent
        thickness,
        cv2.LINE_AA,
    )

    return montage


def export(
    final_bgr: np.ndarray,
    out_dir: str | Path,
    name: str,
    original_bgr: np.ndarray | None = None,
    cfg: Any = None,
) -> ExportResult:
    """Export the final processed image and optional before/after comparison montage.

    Args:
        final_bgr: Processed BGR image (H, W, 3), uint8.
        out_dir: Directory path where output files will be written.
        name: Base filename without extension (e.g. 'product_textile').
        original_bgr: Optional raw input image for before/after montage generation.
        cfg: Optional configuration dictionary or object.

    Returns:
        ExportResult containing paths and file metadata.
    """
    start_time = time.perf_counter()

    output_dir = Path(out_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Clean name (remove existing extensions if provided)
    base_name = Path(name).stem

    # Save final e-commerce image as JPEG quality 95
    final_filename = f"{base_name}.jpg"
    final_path = output_dir / final_filename
    jpeg_params = [int(cv2.IMWRITE_JPEG_QUALITY), 95]
    cv2.imwrite(str(final_path), final_bgr, jpeg_params)

    # Generate before/after montage if original image is provided
    montage_path = None
    montage_filename = None
    if original_bgr is not None:
        try:
            montage_filename = f"before_after_{base_name}.jpg"
            montage_file_path = output_dir / montage_filename
            montage_img = create_before_after_montage(original_bgr, final_bgr)
            cv2.imwrite(str(montage_file_path), montage_img, jpeg_params)
            montage_path = str(montage_file_path)
            logger.info("Saved before/after montage to %s", montage_file_path)
        except Exception as e:
            logger.warning("Failed to generate before/after montage: %s", e)

    file_size_bytes = final_path.stat().st_size if final_path.exists() else 0
    duration_ms = round((time.perf_counter() - start_time) * 1000, 2)

    h, w = final_bgr.shape[:2]
    metadata = {
        "filename": final_filename,
        "width": w,
        "height": h,
        "size_bytes": file_size_bytes,
        "montage_filename": montage_filename,
        "montage_path": montage_path,
        "duration_ms": duration_ms,
    }

    return ExportResult(
        image_path=str(final_path),
        montage_path=montage_path,
        metadata=metadata,
    )


def export_image(image: Any, cfg: Any = None) -> tuple[Any, dict]:
    """Compatibility wrapper for Phase 1 stub."""
    return image, {"stage": "export", "status": "completed"}

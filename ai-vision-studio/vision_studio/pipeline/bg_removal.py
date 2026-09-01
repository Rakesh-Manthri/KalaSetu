from typing import Any


def remove_background(image: Any, cfg: Any = None) -> tuple[Any, Any, Any, dict]:
    """Remove background from image (Phase 1 stub).

    Returns:
        tuple of (image, mask, bbox, metadata)
    """
    return image, None, None, {"stage": "bg_removal", "status": "skipped_stub"}

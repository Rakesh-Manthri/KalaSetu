from typing import Any


def validate_image(image: Any, cfg: Any = None) -> tuple[Any, dict]:
    """Validate image format, dimensions, and limits (Phase 1 stub)."""
    return image, {"stage": "validate", "status": "valid"}

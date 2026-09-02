"""
KalaSetu AI Vision Studio Service
Integrates offline CPU VisionStudio pipeline (SIH PS 26090) with the master FastAPI backend.
Robust against missing system libraries / optional dependencies in cloud deployments (Render, Railway, etc.).
"""

import os
import sys
import uuid
import tempfile
import asyncio
import logging
from pathlib import Path
from typing import Any, Literal
from PIL import Image, ImageEnhance

logger = logging.getLogger(__name__)

# Ensure ai-vision-studio package is discoverable if it exists on disk
_ai_vision_studio_dir = (Path(__file__).resolve().parent.parent.parent / "ai-vision-studio").resolve()
if _ai_vision_studio_dir.exists() and str(_ai_vision_studio_dir) not in sys.path:
    sys.path.insert(0, str(_ai_vision_studio_dir))

# Safe optional import of vision_studio
HAS_VISION_STUDIO = False
try:
    from vision_studio import VisionStudio, EnhanceRequest, EnhanceOptions, EnhanceResponse
    from vision_studio.config import Settings
    from vision_studio.utils.errors import (
        VisionStudioError,
        IMAGE_TOO_BLURRY,
        IMAGE_TOO_LARGE,
        INVALID_IMAGE,
        UNSUPPORTED_FORMAT,
        TIMEOUT,
        STAGE_FAILED,
    )
    HAS_VISION_STUDIO = True
    logger.info("Successfully loaded production VisionStudio AI engine")
except Exception as e:
    logger.warning("VisionStudio AI engine not loaded (%s). Using Pillow fallback processor.", e)
    IMAGE_TOO_BLURRY = "IMAGE_TOO_BLURRY"
    IMAGE_TOO_LARGE = "IMAGE_TOO_LARGE"
    INVALID_IMAGE = "INVALID_IMAGE"
    UNSUPPORTED_FORMAT = "UNSUPPORTED_FORMAT"
    TIMEOUT = "TIMEOUT"
    STAGE_FAILED = "STAGE_FAILED"

# Determine output directory for static serving
_outputs_candidates = [
    Path(__file__).resolve().parent.parent / "outputs",
    Path(__file__).resolve().parent.parent.parent / "ai-vision-studio" / "outputs",
    Path("outputs").resolve(),
]
OUTPUTS_DIR = next((p for p in _outputs_candidates if p.parent.exists()), _outputs_candidates[0])
OUTPUTS_DIR.mkdir(parents=True, exist_ok=True)

# User-friendly messages for mobile artisans
ERROR_USER_MESSAGES = {
    IMAGE_TOO_BLURRY: "Photo is blurry. Please hold steady, tap the product to focus, and take another shot.",
    IMAGE_TOO_LARGE: "Photo size exceeds the 15MB limit. Please take a photo at standard resolution.",
    INVALID_IMAGE: "Unable to read image file. Please capture or select a valid photo.",
    UNSUPPORTED_FORMAT: "Unsupported image format. Please use JPEG or PNG.",
    TIMEOUT: "Image enhancement timed out. Please try again with 'balanced' or 'fast' mode.",
    "EMPTY_MASK": "Could not clearly distinguish the craft from the background. Please ensure good lighting and contrast.",
    STAGE_FAILED: "Image enhancement encountered an error. Please try taking another photo.",
}

_studio: Any = None


def get_vision_studio() -> Any:
    """Retrieve singleton VisionStudio instance if available."""
    global _studio
    if HAS_VISION_STUDIO and _studio is None:
        try:
            cfg = Settings(output_dir=str(OUTPUTS_DIR))
            _studio = VisionStudio(config=cfg)
            logger.info("Initialized master VisionStudio singleton pointing to outputs: %s", OUTPUTS_DIR)
        except Exception as e:
            logger.warning("Could not initialize VisionStudio instance: %s", e)
            _studio = None
    return _studio


def format_user_error(code: str, fallback_message: str = "") -> str:
    """Translate an error code into an actionable, artisan-friendly message."""
    if code in ERROR_USER_MESSAGES:
        return ERROR_USER_MESSAGES[code]
    return fallback_message or "Image enhancement encountered an issue. Please try again."


def _pillow_fallback_enhance(image_bytes: bytes, original_filename: str) -> dict[str, Any]:
    """Pillow-based high-quality enhancement fallback when OpenCV/ONNX isn't available."""
    output_filename = f"enhanced_{uuid.uuid4().hex[:8]}_{Path(original_filename).name}"
    output_path = OUTPUTS_DIR / output_filename

    try:
        temp_input = tempfile.NamedTemporaryFile(delete=False)
        temp_input.write(image_bytes)
        temp_input.flush()
        temp_input.close()

        with Image.open(temp_input.name) as img:
            img = img.convert("RGB")

            # 1. Lighting & contrast enhancement
            enhancer = ImageEnhance.Contrast(img)
            img = enhancer.enhance(1.15)
            enhancer = ImageEnhance.Brightness(img)
            img = enhancer.enhance(1.05)
            enhancer = ImageEnhance.Sharpness(img)
            img = enhancer.enhance(1.2)

            # 2. 1:1 Square studio framing (1000x1000)
            target_size = (1000, 1000)
            canvas = Image.new("RGB", target_size, "#FFFFFF")

            img.thumbnail((900, 900), Image.Resampling.LANCZOS)
            offset = ((1000 - img.width) // 2, (1000 - img.height) // 2)
            canvas.paste(img, offset)

            canvas.save(output_path, "JPEG", quality=95)

        try:
            os.unlink(temp_input.name)
        except Exception:
            pass

        image_url = f"/outputs/{output_filename}"
        return {
            "success": True,
            "status": "success",
            "contract_version": "1.0",
            "processed_image_path": str(output_path),
            "image_url": image_url,
            "montage_url": image_url,
            "enhancedImageUrl": image_url,
            "enhancementsApplied": [
                "Lighting & contrast calibrated for e-commerce",
                "1:1 square studio framing (1000x1000)",
                "Pillow studio enhancement applied",
            ],
            "user_message": None,
            "metadata": {"fallback": True, "engine": "Pillow Studio"},
            "errors": [],
        }
    except Exception as e:
        logger.error("Pillow fallback processing failed: %s", e)
        return {
            "success": False,
            "status": "error",
            "contract_version": "1.0",
            "error_code": STAGE_FAILED,
            "user_message": "Could not process image file.",
            "message": str(e),
            "detail": str(e),
            "errors": [{"code": STAGE_FAILED, "message": str(e)}],
        }


async def enhance_image_file(
    image_bytes: bytes,
    original_filename: str = "artisan_craft.jpg",
    quality: Literal["fast", "balanced", "high"] = "balanced",
    remove_background: bool = True,
    correct_lighting: bool = True,
    background_color: str = "#FFFFFF",
) -> dict[str, Any]:
    """Run product image through VisionStudio or Pillow fallback."""
    studio = get_vision_studio()

    # If VisionStudio is unavailable, run Pillow fallback
    if studio is None:
        loop = asyncio.get_running_loop()
        return await loop.run_in_executor(None, _pillow_fallback_enhance, image_bytes, original_filename)

    loop = asyncio.get_running_loop()
    suffix = Path(original_filename).suffix or ".jpg"
    if suffix.lower() not in (".jpg", ".jpeg", ".png", ".webp"):
        suffix = ".jpg"

    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
    temp_path = temp_file.name

    try:
        temp_file.write(image_bytes)
        temp_file.flush()
        temp_file.close()

        validated_quality = quality if quality in ("fast", "balanced", "high") else "balanced"
        options = EnhanceOptions(
            remove_background=remove_background,
            correct_lighting=correct_lighting,
            output_size=(1000, 1000),
            background_color=background_color,
            quality=validated_quality,
        )
        req = EnhanceRequest(image_path=temp_path, options=options)

        response: EnhanceResponse = await loop.run_in_executor(None, studio.enhance, req)

        if response.status == "error" or (response.errors and not response.processed_image_path):
            first_err = response.errors[0] if response.errors else {}
            code = first_err.get("code", STAGE_FAILED)
            raw_msg = first_err.get("message", "Processing failed")
            user_msg = format_user_error(code, raw_msg)
            return {
                "success": False,
                "status": "error",
                "contract_version": response.contract_version,
                "error_code": code,
                "user_message": user_msg,
                "message": user_msg,
                "detail": user_msg,
                "errors": response.errors,
                "metadata": response.metadata,
            }

        processed_name = Path(response.processed_image_path).name if response.processed_image_path else ""
        montage_path = response.metadata.get("montage_path")
        montage_name = Path(montage_path).name if montage_path else ""

        image_url = f"/outputs/{processed_name}" if processed_name else None
        montage_url = f"/outputs/{montage_name}" if montage_name else None

        enhancements_applied = []
        if response.metadata.get("background_removed"):
            enhancements_applied.append("Background isolated & studio backdrop applied")
        if correct_lighting:
            enhancements_applied.append("Lighting & shadows calibrated for e-commerce")
        enhancements_applied.append("1:1 square canvas framing (1000x1000)")
        if montage_url:
            enhancements_applied.append("Before/After comparison montage generated")

        first_err = response.errors[0] if response.errors else None
        error_code = first_err.get("code") if first_err else None
        user_msg = format_user_error(error_code) if error_code else None

        return {
            "success": True,
            "status": response.status,
            "contract_version": response.contract_version,
            "processed_image_path": response.processed_image_path,
            "image_url": image_url,
            "montage_url": montage_url,
            "enhancedImageUrl": image_url,
            "enhancementsApplied": enhancements_applied,
            "user_message": user_msg,
            "metadata": response.metadata,
            "errors": response.errors,
        }
    except Exception as e:
        logger.error("VisionStudio processing exception: %s. Falling back to Pillow.", e)
        return await loop.run_in_executor(None, _pillow_fallback_enhance, image_bytes, original_filename)
    finally:
        if os.path.exists(temp_path):
            try:
                os.unlink(temp_path)
            except Exception:
                pass


def process_product_image_bytes(image_bytes: bytes) -> dict:
    """Synchronous backward-compatibility bridge."""
    studio = get_vision_studio()
    if studio is None:
        return _pillow_fallback_enhance(image_bytes, "artisan_craft.jpg")
    try:
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".jpg")
        temp_path = temp_file.name
        temp_file.write(image_bytes)
        temp_file.flush()
        temp_file.close()

        req = EnhanceRequest(image_path=temp_path, options=EnhanceOptions())
        response = studio.enhance(req)
        if response.status == "error":
            code = response.errors[0]["code"] if response.errors else STAGE_FAILED
            return {
                "success": False,
                "status": "error",
                "error_code": code,
                "user_message": format_user_error(code),
                "errors": response.errors,
            }

        filename = Path(response.processed_image_path).name if response.processed_image_path else ""
        return {
            "success": True,
            "status": response.status,
            "enhancedImageUrl": f"/outputs/{filename}",
            "image_url": f"/outputs/{filename}",
            "metadata": response.metadata,
        }
    except Exception:
        return _pillow_fallback_enhance(image_bytes, "artisan_craft.jpg")
    finally:
        if 'temp_path' in locals() and os.path.exists(temp_path):
            try:
                os.unlink(temp_path)
            except Exception:
                pass

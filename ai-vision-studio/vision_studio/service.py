"""FastAPI service wrapper for AI Vision Studio.

Provides an asynchronous HTTP API for mobile and web clients to submit
artisan product photos for background removal, lighting correction,
and e-commerce standard canvas composition.
"""

from contextlib import asynccontextmanager
import asyncio
import json
import os
from pathlib import Path
import tempfile
from typing import Any

from fastapi import FastAPI, HTTPException, Request, UploadFile, File, Form, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .api import VisionStudio
from .contracts import EnhanceOptions, EnhanceRequest, EnhanceResponse
from .utils.logging import get_logger

logger = get_logger(__name__)

# Global VisionStudio instance
_studio: VisionStudio | None = None


def get_studio() -> VisionStudio:
    """Retrieve or initialize singleton VisionStudio instance."""
    global _studio
    if _studio is None:
        _studio = VisionStudio()
    return _studio


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager to initialize and warm up VisionStudio."""
    global _studio
    logger.info("Initializing VisionStudio instance on startup...")
    _studio = VisionStudio()
    logger.info("VisionStudio service ready to receive requests")
    yield
    logger.info("Shutting down VisionStudio service...")


app = FastAPI(
    title="AI Vision Studio API",
    description="Offline-first, CPU-optimized AI Image Enhancement Service for Marginalized Artisans (SIH PS 26090)",
    version="1.1.0",
    lifespan=lifespan,
)

# Enable CORS for mobile and web clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["Monitoring"])
async def health_check() -> dict[str, Any]:
    """Health check endpoint returning system status and model readiness."""
    studio = get_studio()
    return {
        "status": "healthy",
        "service": "ai-vision-studio",
        "contract_version": "1.0",
        "models_loaded": studio is not None,
        "device": "cpu",
    }


@app.post(
    "/enhance",
    response_model=EnhanceResponse,
    tags=["Enhancement"],
    summary="Enhance product image (JSON body or Multipart Upload)",
)
async def enhance_image(
    request: Request,
) -> EnhanceResponse:
    """Enhance a product image using the 5-stage Vision Studio pipeline.

    Supports two invocation formats:
    1. **JSON Body**: `{"image_path": "path/to/image.jpg", "options": {...}}`
    2. **Multipart Form**: `file` (image binary) + optional form parameters.
    """
    content_type = request.headers.get("content-type", "").lower()
    studio = get_studio()
    loop = asyncio.get_running_loop()

    # 1. Multipart Form Data (File Upload)
    if "multipart/form-data" in content_type:
        try:
            form = await request.form()
        except Exception as e:
            logger.error("Failed to parse multipart form data: %s", e)
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid multipart form data: {e}",
            )

        # Look for uploaded file under 'file' or 'image'
        upload: UploadFile | None = form.get("file") or form.get("image")  # type: ignore
        if not upload or not hasattr(upload, "filename") or not upload.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Missing file in multipart form data (expected 'file' or 'image')",
            )

        suffix = Path(upload.filename).suffix or ".jpg"
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
        temp_path = temp_file.name

        try:
            content = await upload.read()
            temp_file.write(content)
            temp_file.flush()
            temp_file.close()

            # Parse optional options from form fields
            options_dict: dict[str, Any] = {}
            if "options" in form:
                raw_opt = form["options"]
                if isinstance(raw_opt, str):
                    try:
                        options_dict = json.loads(raw_opt)
                    except json.JSONDecodeError:
                        logger.warning("Could not parse 'options' JSON string from form")
                elif isinstance(raw_opt, dict):
                    options_dict = raw_opt

            # Check individual form field overrides
            if "remove_background" in form:
                val = str(form["remove_background"]).lower()
                options_dict["remove_background"] = val not in ("false", "0", "no")
            if "correct_lighting" in form:
                val = str(form["correct_lighting"]).lower()
                options_dict["correct_lighting"] = val not in ("false", "0", "no")
            if "quality" in form:
                options_dict["quality"] = str(form["quality"])
            if "background_color" in form:
                options_dict["background_color"] = str(form["background_color"])

            options = EnhanceOptions.model_validate(options_dict) if options_dict else EnhanceOptions()
            req = EnhanceRequest(image_path=temp_path, options=options)

            # Offload CPU-bound enhancement to worker thread
            response = await loop.run_in_executor(None, studio.enhance, req)
            return response
        finally:
            # Clean up temporary upload file if it still exists
            if os.path.exists(temp_path):
                try:
                    os.unlink(temp_path)
                except Exception as e:
                    logger.warning("Could not delete temporary uploaded file %s: %s", temp_path, e)

    # 2. JSON Request Body
    else:
        try:
            body = await request.json()
        except Exception as e:
            logger.error("Failed to parse JSON body: %s", e)
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid JSON body: {e}",
            )

        try:
            req = EnhanceRequest.model_validate(body)
        except Exception as e:
            logger.error("Invalid EnhanceRequest schema: %s", e)
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Invalid EnhanceRequest payload: {e}",
            )

        # Offload CPU-bound enhancement to worker thread
        response = await loop.run_in_executor(None, studio.enhance, req)
        return response

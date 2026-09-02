"""
KalaSetu AI Image Studio Router
FastAPI router providing the production POST /api/v1/image/enhance endpoint.
Wired to the production offline CPU VisionStudio engine.
"""

from typing import Literal, Any
from pathlib import Path
from fastapi import APIRouter, UploadFile, File, Form, Request, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from services.image_processor import (
    enhance_image_file,
    format_user_error,
    get_vision_studio,
    OUTPUTS_DIR,
)
from vision_studio.contracts import EnhanceRequest, EnhanceOptions, EnhanceResponse
from vision_studio.utils.errors import IMAGE_TOO_BLURRY, STAGE_FAILED

router = APIRouter(prefix="/api/v1/image", tags=["AI Image Studio"])


class EnhanceOptionsSchema(BaseModel):
    remove_background: bool = True
    correct_lighting: bool = True
    background_color: str = "#FFFFFF"
    quality: Literal["fast", "balanced", "high"] = "balanced"


class EnhanceJsonRequest(BaseModel):
    image_path: str
    options: EnhanceOptionsSchema = EnhanceOptionsSchema()


@router.post("/enhance", summary="Enhance product photo using production AI Vision Studio")
async def enhance_image(
    request: Request,
    file: UploadFile | None = File(None),
    image: UploadFile | None = File(None),
    quality: str = Form("balanced"),
    remove_background: bool = Form(True),
    correct_lighting: bool = Form(True),
    background_color: str = Form("#FFFFFF"),
):
    """
    Accepts artisan product photos via Multipart Form Data or JSON body.
    Processes via 100% offline CPU Vision Studio pipeline:
      1. Validation & blur detection (rejects severely blurry photos)
      2. Background removal & studio backdrop
      3. Classical lighting correction & shadow balancing
      4. E-commerce standard 1:1 canvas framing
      5. Before/after montage generation & static export
    """
    content_type = request.headers.get("content-type", "").lower()

    # 1. Handle Multipart Form Data
    if "multipart/form-data" in content_type or file is not None or image is not None:
        upload = file or image
        if upload is None:
            # Check form directly in case of custom field naming
            try:
                form = await request.form()
                upload = form.get("file") or form.get("image")  # type: ignore
                if "quality" in form:
                    quality = str(form["quality"])
                if "remove_background" in form:
                    val = str(form["remove_background"]).lower()
                    remove_background = val not in ("false", "0", "no")
                if "correct_lighting" in form:
                    val = str(form["correct_lighting"]).lower()
                    correct_lighting = val not in ("false", "0", "no")
                if "background_color" in form:
                    background_color = str(form["background_color"])
            except Exception:
                upload = None

        if upload is None or not hasattr(upload, "filename") or not upload.filename:
            return JSONResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                content={
                    "success": False,
                    "status": "error",
                    "error_code": "MISSING_FILE",
                    "user_message": "Please select or capture a product photo to enhance.",
                    "message": "Missing file in multipart form data (expected 'file' or 'image').",
                    "detail": "Please select or capture a product photo to enhance.",
                    "errors": [{"code": "MISSING_FILE", "message": "No file uploaded"}],
                },
            )

        content = await upload.read()
        if not content:
            return JSONResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                content={
                    "success": False,
                    "status": "error",
                    "error_code": "EMPTY_FILE",
                    "user_message": "The uploaded photo is empty. Please capture another shot.",
                    "message": "Uploaded file is 0 bytes.",
                    "detail": "The uploaded photo is empty.",
                    "errors": [{"code": "EMPTY_FILE", "message": "0-byte file received"}],
                },
            )

        # Execute through production VisionStudio service
        result = await enhance_image_file(
            image_bytes=content,
            original_filename=upload.filename,
            quality=quality,  # type: ignore
            remove_background=remove_background,
            correct_lighting=correct_lighting,
            background_color=background_color,
        )

        # Check for processing errors
        if not result.get("success", False) or result.get("status") == "error":
            error_code = result.get("error_code", STAGE_FAILED)
            status_code = status.HTTP_400_BAD_REQUEST
            return JSONResponse(status_code=status_code, content=result)

        return JSONResponse(status_code=status.HTTP_200_OK, content=result)

    # 2. Handle JSON Request Body
    elif "application/json" in content_type:
        try:
            body = await request.json()
            json_req = EnhanceJsonRequest.model_validate(body)
        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                content={
                    "success": False,
                    "status": "error",
                    "error_code": "INVALID_JSON",
                    "user_message": "Invalid request format.",
                    "message": str(e),
                    "detail": str(e),
                },
            )

        img_path = Path(json_req.image_path)
        if not img_path.exists():
            return JSONResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                content={
                    "success": False,
                    "status": "error",
                    "error_code": "FILE_NOT_FOUND",
                    "user_message": f"Image file not found at path: {json_req.image_path}",
                    "message": "File not found",
                    "detail": "File not found",
                },
            )

        image_bytes = img_path.read_bytes()
        result = await enhance_image_file(
            image_bytes=image_bytes,
            original_filename=img_path.name,
            quality=json_req.options.quality,
            remove_background=json_req.options.remove_background,
            correct_lighting=json_req.options.correct_lighting,
            background_color=json_req.options.background_color,
        )

        if not result.get("success", False) or result.get("status") == "error":
            return JSONResponse(status_code=status.HTTP_400_BAD_REQUEST, content=result)

        return JSONResponse(status_code=status.HTTP_200_OK, content=result)

    # Unsupported Media Type
    return JSONResponse(
        status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
        content={
            "success": False,
            "status": "error",
            "error_code": "UNSUPPORTED_MEDIA_TYPE",
            "user_message": "Expected multipart/form-data with photo upload or application/json.",
            "message": f"Unsupported content-type: {content_type}",
            "detail": "Unsupported content-type",
        },
    )


@router.get("/health", summary="Check AI Vision Studio model status")
async def vision_health():
    """Verify Vision Studio engine readiness."""
    studio = get_vision_studio()
    return {
        "status": "healthy",
        "engine": "VisionStudio 1.1.0",
        "output_dir": str(OUTPUTS_DIR),
        "device": "cpu",
        "ready": studio is not None,
    }

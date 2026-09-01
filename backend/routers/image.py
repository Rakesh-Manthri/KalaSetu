from fastapi import APIRouter, UploadFile, File
from services.image_processor import process_product_image_bytes

router = APIRouter(prefix="/api/v1/image", tags=["AI Image Studio"])

@router.post("/enhance")
async def enhance_image(file: UploadFile = File(...)):
    contents = await file.read()
    result = process_product_image_bytes(contents)
    return result

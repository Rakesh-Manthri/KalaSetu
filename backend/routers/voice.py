from fastapi import APIRouter, UploadFile, File, Form
from pydantic import BaseModel
from typing import Optional
from services.voice_extractor import extract_product_details
from services.pricing_engine import calculate_smart_price

router = APIRouter(prefix="/api/v1/voice", tags=["Voice & AI Extraction"])

class VoiceExtractRequest(BaseModel):
    transcript: str
    language: Optional[str] = "en"

@router.post("/transcribe-and-extract")
async def transcribe_and_extract(
    audio: Optional[UploadFile] = File(None),
    transcript: Optional[str] = Form(None),
    language: Optional[str] = Form("en")
):
    text = transcript or "Pochampally Ikat cotton saree handwoven pure cotton indigo red"
    extracted = extract_product_details(text, language)
    pricing = calculate_smart_price(extracted["craftType"])
    
    return {
        "success": True,
        "transcript": text,
        "language": language,
        "extractedMetadata": extracted,
        "suggestedPricing": pricing
    }

from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from services.pricing_engine import calculate_smart_price

router = APIRouter(prefix="/api/v1/pricing", tags=["Smart Pricing Engine"])

class PricingRequest(BaseModel):
    category: str
    description: Optional[str] = ""
    materialCost: Optional[float] = None
    laborCost: Optional[float] = None

@router.post("/calculate")
async def calculate_price(req: PricingRequest):
    return calculate_smart_price(
        craft_type=req.category,
        custom_material=req.materialCost,
        custom_labor=req.laborCost
    )

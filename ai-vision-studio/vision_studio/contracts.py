from pydantic import BaseModel
from typing import Literal

class EnhanceOptions(BaseModel):
    remove_background: bool = True
    correct_lighting: bool = True
    output_size: tuple[int, int] = (1000, 1000)
    background_color: str = "#FFFFFF"
    quality: Literal["fast", "balanced", "high"] = "balanced"

class EnhanceRequest(BaseModel):
    contract_version: str = "1.0"
    image_path: str
    options: EnhanceOptions = EnhanceOptions()

class EnhanceResponse(BaseModel):
    contract_version: str = "1.0"
    status: Literal["success", "partial", "error"]
    processed_image_path: str | None = None
    metadata: dict = {}
    errors: list[dict] = []

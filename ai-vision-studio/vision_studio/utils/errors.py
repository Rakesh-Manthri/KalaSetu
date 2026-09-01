from pydantic import BaseModel


class VisionStudioError(BaseModel):
    code: str
    message: str
    stage: str | None = None

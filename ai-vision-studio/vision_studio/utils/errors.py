from typing import Any

# Standard Error Codes
FILE_NOT_FOUND = "FILE_NOT_FOUND"
INVALID_IMAGE = "INVALID_IMAGE"
UNSUPPORTED_FORMAT = "UNSUPPORTED_FORMAT"
IMAGE_TOO_LARGE = "IMAGE_TOO_LARGE"
IMAGE_TOO_BLURRY = "IMAGE_TOO_BLURRY"
MODEL_LOAD_FAILED = "MODEL_LOAD_FAILED"
STAGE_FAILED = "STAGE_FAILED"
TIMEOUT = "TIMEOUT"

ALL_ERROR_CODES = [
    FILE_NOT_FOUND,
    INVALID_IMAGE,
    UNSUPPORTED_FORMAT,
    IMAGE_TOO_LARGE,
    IMAGE_TOO_BLURRY,
    MODEL_LOAD_FAILED,
    STAGE_FAILED,
    TIMEOUT,
]


def make_error(stage: str, code: str, message: str) -> dict[str, str]:
    """Create a standardized error dictionary for API responses."""
    return {"code": code, "message": message, "stage": stage}


class VisionStudioError(Exception):
    """Base exception class for Vision Studio operations."""

    def __init__(
        self,
        code: str,
        message: str,
        stage: str | None = None,
        details: Any = None,
    ) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.stage = stage or "validate"
        self.details = details

    def to_dict(self) -> dict[str, str]:
        """Convert exception to dictionary representation."""
        return make_error(stage=self.stage, code=self.code, message=self.message)

    def __repr__(self) -> str:
        return f"VisionStudioError(code='{self.code}', stage='{self.stage}', message='{self.message}')"


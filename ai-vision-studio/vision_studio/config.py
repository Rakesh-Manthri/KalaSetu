from functools import lru_cache
from typing import Literal
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Central configuration for Vision Studio."""

    model_dir: str = "./models"
    default_quality: Literal["fast", "balanced", "high"] = "balanced"
    max_image_mb: int = 15
    inference_device: str = "cpu"
    request_timeout_s: float = 20.0
    output_dir: str = "./outputs"
    blur_severe_threshold: float = 15.0
    blur_light_threshold: float = 60.0

    @field_validator("default_quality")
    @classmethod
    def validate_quality(cls, v: str) -> str:
        allowed = {"fast", "balanced", "high"}
        if v not in allowed:
            raise ValueError(f"default_quality must be one of {allowed}, got '{v}'")
        return v

    @field_validator("max_image_mb")
    @classmethod
    def validate_max_mb(cls, v: int) -> int:
        if v <= 0:
            raise ValueError("max_image_mb must be a positive integer")
        return v

    @field_validator("request_timeout_s")
    @classmethod
    def validate_timeout(cls, v: float) -> float:
        if v <= 0:
            raise ValueError("request_timeout_s must be a positive number")
        return v

    model_config = SettingsConfigDict(
        env_prefix="VISION_STUDIO_",
        env_file=".env",
        extra="ignore",
    )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return a cached Settings singleton instance."""
    return Settings()

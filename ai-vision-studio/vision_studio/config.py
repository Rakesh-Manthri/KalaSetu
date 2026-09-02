from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_dir: str = "./models"
    default_quality: str = "balanced"
    max_image_mb: int = 15
    inference_device: str = "cpu"
    blur_severe_threshold: float = 15.0
    blur_light_threshold: float = 60.0

    model_config = SettingsConfigDict(
        env_prefix="VISION_STUDIO_",
        env_file=".env",
        extra="ignore",
    )

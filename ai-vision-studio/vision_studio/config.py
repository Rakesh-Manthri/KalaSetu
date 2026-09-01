from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_dir: str = "./models"
    default_quality: str = "balanced"
    max_image_mb: int = 15
    inference_device: str = "cpu"

    model_config = SettingsConfigDict(
        env_prefix="VISION_STUDIO_",
        env_file=".env",
        extra="ignore",
    )

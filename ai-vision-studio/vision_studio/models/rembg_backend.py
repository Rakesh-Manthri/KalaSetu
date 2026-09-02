import time
from typing import Any
import cv2
import numpy as np
from rembg import remove, new_session

from .base import ModelBackend
from vision_studio.utils.logging import get_logger

logger = get_logger(__name__)


class RembgBackend(ModelBackend):
    """ONNX-based background removal backend using rembg (U2-Net / U2-Netp).

    Implements a lazy-loaded singleton session pool with CPUExecutionProvider.
    """

    _instance: "RembgBackend | None" = None
    _sessions: dict[str, Any] = {}

    def __new__(cls) -> "RembgBackend":
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self) -> None:
        if self._initialized:
            return
        self._initialized = True
        self._quality_config = {
            "fast": {"model": "u2netp", "size": 640},
            "balanced": {"model": "u2net", "size": 768},
            "high": {"model": "u2net", "size": 1024},
        }

    def _get_session(self, model_name: str) -> Any:
        """Get or initialize a cached ONNX Runtime session for the model."""
        if model_name not in self._sessions:
            logger.info("Initializing ONNX session for model: %s (CPUExecutionProvider)", model_name)
            session = new_session(
                model_name=model_name,
                providers=["CPUExecutionProvider"],
            )
            # Warm up session with a dummy inference to avoid first-request latency spikes
            try:
                dummy = np.zeros((32, 32, 3), dtype=np.uint8)
                remove(dummy, session=session, only_mask=True)
            except Exception as e:
                logger.debug("Warmup dummy inference skipped: %s", e)
            self._sessions[model_name] = session
        return self._sessions[model_name]

    def load(self, model_path: str | None = None) -> None:
        """Preload all configured model sessions into memory."""
        for quality, cfg in self._quality_config.items():
            self._get_session(cfg["model"])

    def predict(
        self,
        bgr_image: np.ndarray,
        quality: str = "balanced",
    ) -> tuple[np.ndarray, np.ndarray]:
        """Run background removal inference on a BGR image.

        Args:
            bgr_image: Input image ndarray in BGR format (uint8, shape HxWx3).
            quality: Quality/speed profile: 'fast', 'balanced', or 'high'.

        Returns:
            tuple[np.ndarray, np.ndarray]:
                - foreground_bgr: 3-channel BGR image with background zeroed out (shape HxWx3, uint8)
                - alpha_mask: Grayscale alpha mask (shape HxW, uint8, values 0-255)
        """
        if quality not in self._quality_config:
            logger.warning("Unknown quality '%s', falling back to 'balanced'", quality)
            quality = "balanced"

        config = self._quality_config[quality]
        model_name = config["model"]
        target_size = config["size"]

        session = self._get_session(model_name)

        h, w = bgr_image.shape[:2]
        long_edge = max(h, w)

        # Downscale input to target long edge before rembg for latency optimization
        if long_edge > target_size:
            scale = target_size / float(long_edge)
            new_w = max(1, int(round(w * scale)))
            new_h = max(1, int(round(h * scale)))
            resized_bgr = cv2.resize(bgr_image, (new_w, new_h), interpolation=cv2.INTER_AREA)
        else:
            resized_bgr = bgr_image
            scale = 1.0

        # rembg expects RGB layout
        rgb_input = cv2.cvtColor(resized_bgr, cv2.COLOR_BGR2RGB)

        # Run inference: alpha_matting=False for MVP latency budget
        # (alpha_matting=True is planned as a future quality upgrade for fine textile fringes)
        mask = remove(
            rgb_input,
            session=session,
            only_mask=True,
            alpha_matting=False,
        )

        if not isinstance(mask, np.ndarray):
            mask = np.array(mask)

        # Upscale mask back to normalized original resolution if downscaled
        if scale != 1.0:
            mask = cv2.resize(mask, (w, h), interpolation=cv2.INTER_LINEAR)

        # Ensure mask is 2D uint8
        if mask.ndim == 3:
            mask = mask[:, :, 0]
        mask = mask.astype(np.uint8)

        # Mask the original full-resolution BGR image to preserve sharp details & textile fringes
        foreground_bgr = cv2.bitwise_and(bgr_image, bgr_image, mask=mask)

        return foreground_bgr, mask


_backend_singleton: RembgBackend | None = None


def get_rembg_backend() -> RembgBackend:
    """Return the global singleton instance of RembgBackend."""
    global _backend_singleton
    if _backend_singleton is None:
        _backend_singleton = RembgBackend()
    return _backend_singleton
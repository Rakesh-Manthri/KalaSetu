from typing import Any
import cv2
import numpy as np

from ..utils.errors import IMAGE_TOO_BLURRY, VisionStudioError
from ..utils.logging import get_logger

logger = get_logger(__name__)

# Default Thresholds (centralized and configurable)
BLUR_SEVERE_THRESHOLD: float = 15.0
BLUR_LIGHT_THRESHOLD: float = 60.0


def compute_laplacian_variance(image_bgr: np.ndarray) -> float:
    """Calculate image sharpness score using OpenCV Laplacian variance.

    Converts the BGR image to grayscale and calculates the variance of the
    Laplacian operator (cv2.CV_64F), where higher values indicate sharper edges
    and lower values indicate blurry/smooth images.

    Args:
        image_bgr: Input image as a 3-channel uint8 BGR ndarray.

    Returns:
        float: Laplacian variance score.
    """
    gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
    return float(cv2.Laplacian(gray, cv2.CV_64F).var())


def apply_unsharp_mask(
    image_bgr: np.ndarray,
    sigma: float = 1.0,
    alpha: float = 1.5,
    beta: float = -0.5,
) -> np.ndarray:
    """Apply lightweight OpenCV unsharp masking to enhance image edges.

    Uses a fast Gaussian blur followed by weighted blending:
        sharpened = image * alpha + blurred * beta + gamma

    Requirements met:
    - Fast CPU-only operation (<100ms)
    - Preserves dimensions (H, W)
    - Preserves 3-channel BGR layout
    - Preserves uint8 dtype without overflow/underflow artifacts

    Args:
        image_bgr: 3-channel uint8 BGR image.
        sigma: Standard deviation for Gaussian kernel (sigmaX).
        alpha: Weight for original image (default: 1.5).
        beta: Weight for blurred image (default: -0.5).

    Returns:
        np.ndarray: Sharpened uint8 BGR image.
    """
    blurred = cv2.GaussianBlur(image_bgr, (5, 5), sigmaX=sigma)
    sharpened = cv2.addWeighted(image_bgr, alpha, blurred, beta, 0)
    return sharpened


def process_blur(
    image_bgr: np.ndarray,
    severe_threshold: float = BLUR_SEVERE_THRESHOLD,
    light_threshold: float = BLUR_LIGHT_THRESHOLD,
) -> tuple[np.ndarray, dict[str, Any]]:
    """Evaluate image sharpness and apply unsharp masking if mildly blurry.

    Semantics:
        - variance < severe_threshold:
            -> severely blurry, halt pipeline immediately by raising VisionStudioError(code=IMAGE_TOO_BLURRY)
        - severe_threshold <= variance < light_threshold:
            -> lightly/moderately blurry, apply unsharp mask, return sharpened image with status 'light_blur'
        - variance >= light_threshold:
            -> acceptable sharpness, return unchanged image with status 'sharp'

    Args:
        image_bgr: Normalized uint8 BGR ndarray.
        severe_threshold: Cutoff below which the image is rejected as too blurry.
        light_threshold: Cutoff below which the image receives unsharp masking.

    Returns:
        tuple[np.ndarray, dict[str, Any]]:
            - Processed BGR image ndarray (original if sharp, sharpened if light_blur)
            - Blur metadata dictionary:
                {
                    "blur_score": float,
                    "blur_status": "sharp" | "light_blur" | "severe_blur",
                    "sharpened": bool,
                }

    Raises:
        VisionStudioError: If image variance < severe_threshold with code IMAGE_TOO_BLURRY.
    """
    score = compute_laplacian_variance(image_bgr)
    logger.info(
        "Blur score: %.2f (severe_threshold=%.1f, light_threshold=%.1f)",
        score,
        severe_threshold,
        light_threshold,
    )

    if score < severe_threshold:
        status = "severe_blur"
        logger.warning("Image failed blur check: score=%.2f < %.1f", score, severe_threshold)
        raise VisionStudioError(
            code=IMAGE_TOO_BLURRY,
            message="Your photo looks a bit blurry! Try holding your camera steady or tapping on the product to focus, then snap another photo.",
            stage="validate",
            details={
                "blur_score": score,
                "blur_status": status,
                "threshold": severe_threshold,
            },
        )

    if score < light_threshold:
        status = "light_blur"
        logger.info("Image classified as light_blur (score=%.2f). Applying unsharp mask.", score)
        sharpened_bgr = apply_unsharp_mask(image_bgr)
        return sharpened_bgr, {
            "blur_score": score,
            "blur_status": status,
            "sharpened": True,
        }

    status = "sharp"
    logger.info("Image classified as sharp (score=%.2f). No sharpening needed.", score)
    return image_bgr, {
        "blur_score": score,
        "blur_status": status,
        "sharpened": False,
    }

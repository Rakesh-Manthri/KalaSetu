import argparse
import sys
from pathlib import Path
import cv2
import numpy as np

from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio


def main():
    parser = argparse.ArgumentParser(description="Test AI Vision Studio Background Removal on a real image.")
    parser.add_argument("image_path", help="Path to the input image file (JPEG, PNG, WEBP)")
    parser.add_argument(
        "quality",
        nargs="?",
        default="balanced",
        choices=["fast", "balanced", "high"],
        help="Quality profile (fast, balanced, high). Default: balanced",
    )
    parser.add_argument(
        "--quality",
        dest="opt_quality",
        choices=["fast", "balanced", "high"],
        help="Quality profile via optional flag (fast, balanced, high)",
    )

    args = parser.parse_args()

    image_path = Path(args.image_path)
    quality = args.opt_quality or args.quality or "balanced"

    if not image_path.exists():
        print(f"Error: File not found at '{image_path}'")
        sys.exit(1)

    print(f"Enhancing image: {image_path.resolve()} (quality={quality})...")

    studio = VisionStudio()
    request = EnhanceRequest(
        image_path=str(image_path),
        options=EnhanceOptions(
            remove_background=True,
            correct_lighting=True,
            quality=quality,
        ),
    )

    response = studio.enhance(request)

    print("\n--- Pipeline Result ---")
    print(f"Status: {response.status}")
    if response.errors:
        print(f"Errors: {response.errors}")
        sys.exit(1)

    bg_meta = response.metadata.get("bg_removal", {})
    print(f"Model used: {bg_meta.get('model')}")
    print(f"Duration: {bg_meta.get('duration_ms')} ms")
    print(f"Transparent PNG saved to: {response.processed_image_path}")

    # Generate a Before vs After side-by-side comparison image
    if response.processed_image_path and Path(response.processed_image_path).exists():
        orig_bgr = cv2.imread(str(image_path))
        cutout_bgra = cv2.imread(response.processed_image_path, cv2.IMREAD_UNCHANGED)

        if orig_bgr is not None and cutout_bgra is not None:
            # Match sizes for side-by-side display
            h, w = cutout_bgra.shape[:2]
            orig_resized = cv2.resize(orig_bgr, (w, h))

            # Composite cutout over a clean white canvas
            alpha = (cutout_bgra[:, :, 3].astype(np.float32) / 255.0)[:, :, np.newaxis]
            cutout_bgr = cutout_bgra[:, :, :3]
            white_bg = np.full_like(cutout_bgr, 255)
            composite = (cutout_bgr * alpha + white_bg * (1 - alpha)).astype(np.uint8)

            # Put side-by-side: [Original | Background Removed (White BG)]
            side_by_side = np.hstack([orig_resized, composite])

            out_dir = Path("outputs")
            out_dir.mkdir(parents=True, exist_ok=True)
            stem = image_path.stem
            comp_path = out_dir / f"{stem}_before_after.jpg"
            cv2.imwrite(str(comp_path), side_by_side)
            print(f"Side-by-side comparison saved to: {comp_path}")


if __name__ == "__main__":
    main()

import argparse
import sys
from vision_studio.api import VisionStudio
from vision_studio.contracts import EnhanceOptions, EnhanceRequest


def main(args: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Vision Studio AI Image Enhancement CLI")
    parser.add_argument(
        "--image",
        "-i",
        required=True,
        help="Path to the input image to enhance",
    )
    parser.add_argument(
        "--no-bg-removal",
        action="store_true",
        help="Disable background removal",
    )
    parser.add_argument(
        "--no-lighting",
        action="store_true",
        help="Disable lighting correction",
    )
    parser.add_argument(
        "--quality",
        choices=["fast", "balanced", "high"],
        default="balanced",
        help="Quality preset",
    )

    parsed = parser.parse_args(args)

    options = EnhanceOptions(
        remove_background=not parsed.no_bg_removal,
        correct_lighting=not parsed.no_lighting,
        quality=parsed.quality,
    )
    request = EnhanceRequest(
        image_path=parsed.image,
        options=options,
    )

    studio = VisionStudio()
    response = studio.enhance(request)
    print(response.model_dump_json(indent=2))
    return 0 if response.status in ("success", "partial") else 1


if __name__ == "__main__":
    sys.exit(main())

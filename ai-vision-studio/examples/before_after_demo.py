"""Before/After Demo Builder for SIH Presentation.

Demonstrates the end-to-end AI Vision Studio pipeline:
- Validates raw artisan photo
- Removes complex background
- Enhances color fidelity & lighting
- Scales & centers subject to 1000x1000 standard canvas
- Exports final e-commerce catalog image and side-by-side Before/After montage
"""

import sys
import json
from pathlib import Path

from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio


def main():
    image_path = (
        sys.argv[1]
        if len(sys.argv) > 1
        else str(Path(__file__).parent.parent / "tests" / "fixtures" / "product_textile.jpg")
    )

    print(f"==================================================")
    print(f" KalaSetu AI Vision Studio - E-Commerce Demo")
    print(f"==================================================")
    print(f"Input Image : {image_path}")

    studio = VisionStudio()
    request = EnhanceRequest(
        image_path=image_path,
        options=EnhanceOptions(
            remove_background=True,
            correct_lighting=True,
            output_size=(1000, 1000),
            background_color="#FFFFFF",
            quality="balanced",
        ),
    )

    response = studio.enhance(request)

    print(f"\nPipeline Status : {response.status.upper()}")
    if response.status == "error":
        print(f"Errors          : {json.dumps(response.errors, indent=2)}")
        sys.exit(1)

    print(f"Final Catalog Image : {response.processed_image_path}")
    montage_path = response.metadata.get("montage_path")
    print(f"Before/After Montage: {montage_path}")
    print(f"Total Latency       : {response.metadata.get('duration_ms')} ms")
    print(f"Original Dims       : {response.metadata.get('orig_dims')}")
    print(f"Processed Dims      : {response.metadata.get('processed_dims')}")
    print(f"==================================================")


if __name__ == "__main__":
    main()

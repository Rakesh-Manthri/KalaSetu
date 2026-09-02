import sys
from pathlib import Path
from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio


def main():
    default_sample = str(Path(__file__).parent.parent / "tests" / "fixtures" / "product_textile.jpg")
    image_path = sys.argv[1] if len(sys.argv) > 1 else default_sample
    print(f"Running standalone enhancement on: {image_path}")

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
    print("\n--- Full EnhanceResponse JSON ---")
    print(response.model_dump_json(indent=2))


if __name__ == "__main__":
    main()

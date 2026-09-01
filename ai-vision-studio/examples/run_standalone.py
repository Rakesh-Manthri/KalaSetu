import sys
from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio


def main():
    image_path = sys.argv[1] if len(sys.argv) > 1 else "sample_artisan_handicraft.jpg"
    print(f"Running standalone enhancement on: {image_path}")

    studio = VisionStudio()
    request = EnhanceRequest(
        image_path=image_path,
        options=EnhanceOptions(
            remove_background=True,
            correct_lighting=True,
            quality="balanced",
        ),
    )

    response = studio.enhance(request)
    print("\n--- Response ---")
    print(response.model_dump_json(indent=2))


if __name__ == "__main__":
    main()

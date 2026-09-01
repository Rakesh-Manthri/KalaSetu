# Test Fixtures

This directory contains test fixture images for unit and integration testing of `vision_studio`.

## Fixture Files
- `valid_sample.jpg`: Small valid JPEG image (400x300 RGB).
- `corrupt.jpg`: Corrupted file with non-image text bytes.
- `transparent.png`: Valid RGBA PNG image with transparency channel (`has_alpha=True`).
- `non_product.jpg`: Simple non-product photo (500x500 RGB).
- `unsupported.txt`: Text file used to test `UNSUPPORTED_FORMAT` rejection.
- `oversized.jpg`: Oversized file (>15 MB) used to test `IMAGE_TOO_LARGE` rejection (gitignored).
- `large_dimension.jpg`: Image with long edge > 2000px (3000x2400) to test automatic downscaling.
- `exif_rotated.jpg`: JPEG image with EXIF orientation metadata to test orientation correction.

Note: Fixture files are automatically generated programmatically if absent by `tests/conftest.py`.

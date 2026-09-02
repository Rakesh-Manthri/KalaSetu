# Test Fixtures & Synthetic Datasets

This directory contains offline test fixtures and synthetic craft image datasets designed for testing and hardening the `vision_studio` image enhancement pipeline (SIH PS 26090).

## Fixture Descriptions

| Fixture File | Type / Format | Dimensions | Purpose & Test Scope |
| :--- | :--- | :---: | :--- |
| `product_textile.jpg` | JPEG (`uint8`, RGB) | 600 x 400 | Synthetic artisan handicraft textile fixture with rich crimson tones and gold motifs. Validates background segmentation, Gray-World white balancing, auto-gamma, drop shadow, and export montage. |
| `valid_sample.jpg` | JPEG (`uint8`, RGB) | 400 x 300 | Valid sample artisan product image (terracotta pottery). Validates standard pipeline pass-through and metadata generation. |
| `non_product.jpg` | JPEG (`uint8`, RGB) | 500 x 500 | Simple non-product photo. Validates edge segmentation and generic object handling. |
| `corrupt.jpg` | Binary / Text | N/A (35 B) | Corrupted file header containing non-image text bytes. Validates deterministic rejection with `INVALID_IMAGE` error. |
| `transparent.png` | PNG (`uint8`, RGBA) | 200 x 200 | Pre-existing transparent PNG with alpha channel. Validates alpha channel handling (`has_alpha=True`) without crashing. |
| `unsupported.txt` | Text file | N/A | Non-image text file. Validates file extension and format rejection with `UNSUPPORTED_FORMAT`. |
| `oversized.jpg` | JPEG | > 15 MB | Oversized file exceeding `max_image_mb` limit. Validates rejection with `IMAGE_TOO_LARGE`. (Generated locally in tests/gitignored). |
| `large_dimension.jpg` | JPEG (`uint8`, RGB) | 3000 x 2400 | High-resolution artisan photo with long edge > 2000px. Validates automatic downscaling to `2000px` long edge. |
| `exif_rotated.jpg` | JPEG (`uint8`, RGB) | 400 x 300 | Image with EXIF orientation metadata (tags 3, 6, 8). Validates automatic EXIF orientation normalization. |
| `plain_uniform.jpg` | JPEG (`uint8`, RGB) | 400 x 300 | Uniform mid-gray image with no foreground object. Validates `EMPTY_MASK` detection and handling. |

## Programmatic Generation
Fixtures are created programmatically by `tests/conftest.py` if absent, ensuring that tests run 100% offline with zero external network dependencies.

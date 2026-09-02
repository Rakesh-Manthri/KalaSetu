from pathlib import Path
import numpy as np
from PIL import Image
import pytest

FIXTURES_DIR = Path(__file__).parent / "fixtures"


@pytest.fixture(scope="session", autouse=True)
def setup_test_fixtures():
    """Ensure all required test fixtures exist before running tests."""
    FIXTURES_DIR.mkdir(parents=True, exist_ok=True)

    # 1. valid_sample.jpg (400x300 RGB)
    valid_jpg_path = FIXTURES_DIR / "valid_sample.jpg"
    if not valid_jpg_path.exists():
        arr = np.zeros((300, 400, 3), dtype=np.uint8)
        arr[:, :, 0] = 120  # R
        arr[:, :, 1] = 180  # G
        arr[:, :, 2] = 220  # B
        img = Image.fromarray(arr, mode="RGB")
        img.save(valid_jpg_path, format="JPEG", quality=95)

    # 2. corrupt.jpg (plain text bytes, corrupt image)
    corrupt_jpg_path = FIXTURES_DIR / "corrupt.jpg"
    with open(corrupt_jpg_path, "wb") as f:
        f.write(b"NOT_A_VALID_JPEG_IMAGE_DATA_CORRUPT")

    # 3. transparent.png (200x200 RGBA with transparent areas)
    transparent_png_path = FIXTURES_DIR / "transparent.png"
    if not transparent_png_path.exists():
        rgba_arr = np.zeros((200, 200, 4), dtype=np.uint8)
        rgba_arr[50:150, 50:150] = [200, 50, 50, 200]  # semi-transparent square
        img = Image.fromarray(rgba_arr, mode="RGBA")
        img.save(transparent_png_path, format="PNG")

    # 4. non_product.jpg (500x500 RGB gradient)
    non_product_path = FIXTURES_DIR / "non_product.jpg"
    if not non_product_path.exists():
        gradient = np.tile(np.linspace(0, 255, 500, dtype=np.uint8), (500, 1))
        arr = np.stack([gradient, gradient.T, np.fliplr(gradient)], axis=-1)
        img = Image.fromarray(arr, mode="RGB")
        img.save(non_product_path, format="JPEG", quality=90)

    # 5. unsupported.txt
    unsupported_txt_path = FIXTURES_DIR / "unsupported.txt"
    with open(unsupported_txt_path, "w", encoding="utf-8") as f:
        f.write("This is a plain text file, not a valid image format.")

    # 6. oversized.jpg (16 MB sparse/zero file)
    oversized_path = FIXTURES_DIR / "oversized.jpg"
    if not oversized_path.exists() or oversized_path.stat().st_size < 16 * 1024 * 1024:
        with open(oversized_path, "wb") as f:
            # 16 MB of bytes
            f.seek(16 * 1024 * 1024)
            f.write(b"\0")

    # 7. large_dimension.jpg (3000x2400 RGB image)
    large_dim_path = FIXTURES_DIR / "large_dimension.jpg"
    if not large_dim_path.exists():
        # Create a 3000x2400 image efficiently
        img = Image.new("RGB", (3000, 2400), color=(100, 150, 200))
        img.save(large_dim_path, format="JPEG", quality=80)

    # 8. exif_rotated.jpg (EXIF orientation tag = 6 -> 90 CW)
    exif_path = FIXTURES_DIR / "exif_rotated.jpg"
    if not exif_path.exists():
        img = Image.new("RGB", (300, 100), color=(50, 100, 150))
        exif = img.getexif()
        exif[0x0112] = 6  # Orientation: 6 (Rotate 90 CW)
        img.save(exif_path, format="JPEG", exif=exif)

    # 9. product_textile.jpg (simulated textile product with distinct foreground)
    product_textile_path = FIXTURES_DIR / "product_textile.jpg"
    if not product_textile_path.exists():
        # Create a synthetic textile-like image: colored rectangle on different background
        arr = np.zeros((400, 600, 3), dtype=np.uint8)
        # Background: light gray
        arr[:, :] = [200, 200, 200]
        # Foreground: textile-colored rectangle (simulating a fabric piece)
        arr[80:320, 150:450] = [180, 100, 60]  # Terracotta/brown textile color
        # Add some "fringe" details - thin lines at edges
        arr[75:80, 150:450] = [160, 80, 40]
        arr[320:325, 150:450] = [160, 80, 40]
        arr[80:320, 145:150] = [160, 80, 40]
        arr[80:320, 450:455] = [160, 80, 40]
        img = Image.fromarray(arr, mode="RGB")
        img.save(product_textile_path, format="JPEG", quality=95)

    return FIXTURES_DIR

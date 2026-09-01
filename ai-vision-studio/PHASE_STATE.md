# Phase State Tracking — AI Vision Studio

## Current Status: Phase 2 Complete (Input Validation & Image I/O)

### Completed Tasks
- [x] **Phase 1**: Package skeleton, pydantic contract v1.0, configuration, logging, pipeline stubs, CLI, smoke tests.
- [x] **Phase 2**: Real input validation (`vision_studio/pipeline/validate.py`) and robust image I/O (`vision_studio/utils/image_io.py`).
- [x] **Phase 2**: Standardized error codes and `make_error()` helper (`vision_studio/utils/errors.py`).
- [x] **Phase 2**: Comprehensive test fixtures and offline test suite (`tests/test_validation.py`, `tests/conftest.py`, 17/17 tests passing).
- [x] **Phase 2**: Integrated validation in `VisionStudio.enhance()`, safely rejecting bad inputs with clean error responses.

---

## HANDOFF -> PHASE 3 (Background Removal with rembg)

### 1. Validation Function Signature & Return Shape
```python
from pathlib import Path
import numpy as np

def validate(
    image_path: str | Path,
    max_mb: float = 15.0,
    max_edge: int = 2000,
) -> tuple[np.ndarray, dict[str, Any]]:
    """Loads, validates, EXIF-transposes, downscales, and normalizes input image.

    Returns:
        tuple[np.ndarray, dict]:
            - image_arr: np.ndarray, dtype=np.uint8, layout=BGR (OpenCV standard), shape=(H, W, 3), max(H, W) <= 2000
            - metadata: dict containing:
                {
                    "orig_dims": (width, height),
                    "norm_dims": (width, height),
                    "format": "jpeg" | "png" | "webp",
                    "has_alpha": bool,
                }

    Raises:
        VisionStudioError: If validation fails with a specific error code.
    """
```

### 2. Normalized Image Invariant (Contract for Downstream Stages)
Every downstream pipeline stage (e.g. `bg_removal`, `lighting`, `composition`) receives a validated image adhering strictly to:
- **Type**: `numpy.ndarray` (`dtype=np.uint8`)
- **Layout**: 3-channel **BGR** (OpenCV standard channel order)
- **Dimensions**: `max(height, width) <= 2000` (aspect ratio preserved, scaled via `INTER_AREA`)
- **EXIF**: Orientation tag transposed to standard upright orientation before conversion
- **Metadata dictionary**: Guaranteed keys `["orig_dims", "norm_dims", "format", "has_alpha"]`

### 3. Full Standard Error Code List (`vision_studio/utils/errors.py`)
| Error Code | Meaning / Scenario |
| :--- | :--- |
| `FILE_NOT_FOUND` | Path does not exist or is not a file |
| `INVALID_IMAGE` | File is corrupted, truncated, or unreadable by image parser |
| `UNSUPPORTED_FORMAT` | Format not in allowed list (JPEG, PNG, WEBP), or unsupported HEIC |
| `IMAGE_TOO_LARGE` | File size exceeds maximum allowed limit (default 15 MB) |
| `MODEL_LOAD_FAILED` | Rembg / ONNX model weights failed to load / initialize |
| `STAGE_FAILED` | An internal processing stage encountered an unrecoverable failure |
| `TIMEOUT` | Processing stage exceeded maximum execution time budget |

### 4. HEIC Support Status
- Pillow in the baseline environment does not include native HEIC support.
- Attempting to load HEIC files safely returns `UNSUPPORTED_FORMAT` with a clean error message suggesting JPEG/PNG conversion.
- No heavy external binary dependencies (`pillow-heif` / `libheif`) were added to maintain 100% offline, lightweight installation.

### 5. API Behavior
- `VisionStudio.enhance(request)` executes `validate(req.image_path)` before downstream processing.
- If validation fails, `VisionStudio.enhance()` catches the `VisionStudioError` and returns `EnhanceResponse(status="error", processed_image_path=None, errors=[{"code": ..., "message": ..., "stage": "validate"}], metadata={})`. No uncaught tracebacks escape.
- When valid, downstream pipeline stub returns `EnhanceResponse(status="success", metadata={"phase": 2, "image_metadata": ...})`.

### 6. Verification
Run all tests offline:
```bash
pytest tests/test_validation.py tests/test_smoke.py -v
```


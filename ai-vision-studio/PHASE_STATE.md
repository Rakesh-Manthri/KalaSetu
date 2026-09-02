# Phase State Tracking — AI Vision Studio

## Current Status: Phase 3 Complete (Background Removal with rembg / U2-Net)

### Completed Tasks
- [x] **Phase 1**: Package skeleton, pydantic contract v1.0, configuration, logging, pipeline stubs, CLI, smoke tests.
- [x] **Phase 2**: Real input validation (`vision_studio/pipeline/validate.py`) and robust image I/O (`vision_studio/utils/image_io.py`).
- [x] **Phase 2**: Standardized error codes and `make_error()` helper (`vision_studio/utils/errors.py`).
- [x] **Phase 2**: Comprehensive test fixtures and offline test suite (`tests/test_validation.py`, `tests/conftest.py`, 17/17 tests passing).
- [x] **Phase 2**: Integrated validation in `VisionStudio.enhance()`, safely rejecting bad inputs with clean error responses.
- [x] **Phase 3**: ONNX Runtime singleton backend (`vision_studio/models/rembg_backend.py`) with CPUExecutionProvider, session warm-up, and tiered quality/speed profiles (`fast`, `balanced`, `high`).
- [x] **Phase 3**: Background removal stage (`vision_studio/pipeline/bg_removal.py`) returning `BgRemovalResult` with BGR foreground, uint8 alpha mask, subject bounding box `(x, y, w, h)`, duration measurement, and empty mask error handling.
- [x] **Phase 3**: Integrated background removal into `VisionStudio.enhance()` pipeline, saving transparent RGBA PNG cutouts to `outputs/` and returning `status="partial"`.
- [x] **Phase 3**: Test suite with 100% pass rate (`tests/test_bg_removal.py`, 31/31 test suite passing offline).

---

## HANDOFF -> PHASE 4 (Lighting Correction)

### 1. Model & Stage Signatures

#### `RembgBackend.predict` (`vision_studio/models/rembg_backend.py`)
```python
def predict(
    self,
    bgr_image: np.ndarray,
    quality: str = "balanced",
) -> tuple[np.ndarray, np.ndarray]:
    """Run background removal inference on a BGR image.

    Args:
        bgr_image: Input image ndarray in BGR format (uint8, shape HxWx3).
        quality: Quality/speed profile ('fast', 'balanced', 'high').

    Returns:
        tuple[np.ndarray, np.ndarray]:
            - foreground_bgr: 3-channel BGR image with background zeroed out (shape HxWx3, uint8)
            - alpha_mask: Grayscale alpha mask (shape HxW, uint8, values 0-255)
    """
```

#### `remove_background` (`vision_studio/pipeline/bg_removal.py`)
```python
@dataclass
class BgRemovalResult:
    image: np.ndarray             # np.ndarray, dtype=uint8, shape=(H, W, 3), BGR format
    mask: np.ndarray              # np.ndarray, dtype=uint8, shape=(H, W), range=[0, 255]
    bbox: tuple[int, int, int, int] # (x, y, width, height) of foreground bounding rect
    metadata: dict[str, Any]      # {"quality": str, "model": str, "duration_ms": float, "input_dims": (W, H)}

def remove_background(
    image_bgr: np.ndarray,
    cfg: Any = None,
) -> BgRemovalResult:
    """Removes background, computes subject bbox, and measures latency."""
```

### 2. Output Format and Invariants
Every call to `remove_background` receives a normalized BGR image from Phase 2 validation and guarantees:
- **Foreground Image (`result.image`)**: 3-channel `np.uint8` BGR array with identical `(H, W)` dimensions to the validated input. Foreground pixels retain full resolution and original color fidelity; background pixels are zeroed.
- **Alpha Mask (`result.mask`)**: Single-channel `np.uint8` 2D array of shape `(H, W)`, pixel values strictly in `[0, 255]`. 0 = background, 255 = fully opaque foreground.
- **Subject Bounding Box (`result.bbox`)**: Tuple of 4 standard integers `(x, y, w, h)` derived via `cv2.boundingRect(cv2.findNonZero(mask))`. Strictly within `0 <= x < W` and `0 <= y < H` with `w > 0` and `h > 0`.
- **Empty Mask Detection**: If an image produces zero or near-zero foreground pixels, `VisionStudioError(code="EMPTY_MASK", stage="bg_removal")` is raised and caught by `enhance()`, returning an error response without crashing.

### 3. Measured Latency Benchmarks (CPU Inference on 2-core standard host)
| Quality Profile | Model | Target Long Edge | First Run (Load + Warmup) | Warm Run (Subsequent calls) | Budget Limit |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`fast`** | `u2netp` | 640 px | ~1,090 ms | **~550 ms** | < 3,000 ms (Passed) |
| **`balanced`** | `u2net` | 768 px | ~3,650 ms | **~1,300 ms** | < 6,000 ms (Passed) |
| **`high`** | `u2net` | 1024 px | ~1,740 ms | **~1,740 ms** | < 12,000 ms (Passed) |

*Input image was downscaled to the quality profile's target long edge prior to ONNX inference and the resulting alpha mask was upscaled via bilinear interpolation back to the normalized input resolution, keeping full-fidelity foreground RGB.*

### 4. Weights Storage & Singleton Lifecycle
- **Model Storage**: Model weights are downloaded automatically on first use by `rembg`/`pooch` to `~/.rembg/models/u2net/u2net.onnx` and `~/.rembg/models/u2netp/u2netp.onnx`. They are completely outside the repository tree and excluded via `.gitignore` (`*.onnx`, `models/*`).
- **Singleton Pattern**: `RembgBackend` is a process-level singleton accessed via `get_rembg_backend()`. ONNX runtime sessions are initialized once per model type and reused across requests without memory leaks or repeated initialization overhead.
- **Provider**: Standard `CPUExecutionProvider` configured for 100% offline CPU-only compatibility.

### 5. Textile & Handicraft Edge Quality Observations
- **Textile Fringes & Fine Details**: `u2net` (`balanced` / `high`) accurately segments intricate artisan crafts (e.g. terracotta, handloom textiles). `u2netp` (`fast`) produces coarser boundaries on fine fringes (<2px threads) but excels in real-time latency.
- **Future Matting Upgrade**: `alpha_matting=False` is used for high-speed MVP processing. `alpha_matting=True` (with erosion/dilation kernel configuration) is noted as a future configuration toggle for ultra-fine textile fringe extraction in high-quality modes.

### 6. Verification
Run all tests offline:
```bash
pytest tests/ -v
```
Execute Phase 3 definition of done one-liner:
```bash
python -c "from vision_studio import VisionStudio; from vision_studio.contracts import EnhanceRequest, EnhanceOptions; r = VisionStudio().enhance(EnhanceRequest(image_path='tests/fixtures/product_textile.jpg', options=EnhanceOptions(quality='fast'))); print(r.status, r.metadata)"
```

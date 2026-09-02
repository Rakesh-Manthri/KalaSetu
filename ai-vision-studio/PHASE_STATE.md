# Phase State Tracking — AI Vision Studio

## Current Status: Phase 4 Complete (Lighting Correction with Gray-World WB, Auto-Gamma, and LAB CLAHE)

### Completed Tasks
- [x] **Phase 1**: Package skeleton, pydantic contract v1.0, configuration, logging, pipeline stubs, CLI, smoke tests.
- [x] **Phase 2**: Real input validation (`vision_studio/pipeline/validate.py`) and robust image I/O (`vision_studio/utils/image_io.py`).
- [x] **Phase 2**: Standardized error codes and `make_error()` helper (`vision_studio/utils/errors.py`).
- [x] **Phase 2**: Comprehensive test fixtures and offline test suite (`tests/test_validation.py`, `tests/conftest.py`, 17/17 tests passing).
- [x] **Phase 2**: Integrated validation in `VisionStudio.enhance()`, safely rejecting bad inputs with clean error responses.
- [x] **Phase 2.5**: Deterministic "Detect and Guide" blur quality check with OpenCV Laplacian variance (`vision_studio/pipeline/blur.py`).
- [x] **Phase 2.5**: Added configurable thresholds `BLUR_SEVERE_THRESHOLD` (15.0) and `BLUR_LIGHT_THRESHOLD` (60.0).
- [x] **Phase 2.5**: Added fast CPU-only unsharp masking for mildly blurry inputs before background removal.
- [x] **Phase 2.5**: Extended standardized error codes with `IMAGE_TOO_BLURRY` and mobile UX guidance.
- [x] **Phase 2.5**: Comprehensive blur test suite (`tests/test_blur_detection.py`, 42/42 tests passing across full test suite).
- [x] **Phase 3**: ONNX Runtime singleton backend (`vision_studio/models/rembg_backend.py`) with CPUExecutionProvider, session warm-up, and tiered quality/speed profiles (`fast`, `balanced`, `high`).
- [x] **Phase 3**: Background removal stage (`vision_studio/pipeline/bg_removal.py`) returning `BgRemovalResult` with BGR foreground, uint8 alpha mask, subject bounding box `(x, y, w, h)`, duration measurement, and empty mask error handling.
- [x] **Phase 3**: Integrated background removal into `VisionStudio.enhance()` pipeline, saving transparent RGBA PNG cutouts to `outputs/` and returning `status="partial"`.
- [x] **Phase 3**: Test suite with 100% pass rate (`tests/test_bg_removal.py`, 42/42 test suite passing offline).
- [x] **Phase 4**: Classical CV lighting correction stage (`vision_studio/pipeline/lighting.py`) with Gray-World white balance, auto-gamma correction, LAB CLAHE shadow/contrast enhancement, and bitwise masked foreground blending.
- [x] **Phase 4**: Integrated lighting correction into `VisionStudio.enhance()`, updating output cutouts and recording execution metrics (`white_balance_gains`, `gamma_applied`, `mean_luminance_before/after`).
- [x] **Phase 4**: Comprehensive test suite (`tests/test_lighting.py`, 51/51 tests passing across full test suite).

---

## Phase 2.5 Blur Detection Specifications

### 1. Pipeline Location & Flow
`Input Image -> load_image() (I/O, EXIF, normalization, <=2000px) -> compute_laplacian_variance() -> process_blur() -> (optional unsharp mask) -> Phase 3 rembg`

### 2. Sharpness Metric & Laplacian Formula
Sharpness is calculated strictly on the grayscale normalized image using the variance of the 64-bit float Laplacian kernel:
```python
gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
blur_score = float(cv2.Laplacian(gray, cv2.CV_64F).var())
```

### 3. Thresholds & Classification
Configurable thresholds centralized in `vision_studio/config.py` and `vision_studio/pipeline/blur.py`:
- `BLUR_SEVERE_THRESHOLD = 15.0`
- `BLUR_LIGHT_THRESHOLD = 60.0`

| Variance Score Range | Status (`blur_status`) | Action | Metadata `sharpened` | Rembg Executed? |
| :--- | :--- | :--- | :--- | :--- |
| `score < 15.0` | `"severe_blur"` | Raise `VisionStudioError(code="IMAGE_TOO_BLURRY")` | N/A (aborts) | **No** (halts before rembg) |
| `15.0 <= score < 60.0` | `"light_blur"` | Apply fast unsharp mask | `True` | **Yes** (passes sharpened image) |
| `score >= 60.0` | `"sharp"` | None (continue unchanged) | `False` | **Yes** (passes original BGR) |

### 4. Measured Laplacian Variances (Empirical Benchmarks)
| Fixture / Image | Condition | Measured Variance | Classification |
| :--- | :--- | :--- | :--- |
| `product_textile.jpg` | Original sharp synthetic textile | **101.60** | `sharp` |
| `handpainted-clay-pot...jpg` | Real artisan photo (pot on background) | **50.90** | `light_blur` (receives unsharp mask) |
| `product_textile.jpg` | Mild Gaussian blur (k=3, s=0.7) | **36.75** | `light_blur` |
| `product_textile.jpg` | Moderate Gaussian blur (k=3, s=1.0) | **12.64** | `severe_blur` (rejected) |
| `product_textile.jpg` | Heavy Gaussian blur (k=31, s=10.0) | **0.20** | `severe_blur` (rejected) |

### 5. Unsharp Mask Parameters
```python
blurred = cv2.GaussianBlur(image_bgr, (0, 0), sigmaX=1.0)
sharpened_bgr = cv2.addWeighted(image_bgr, 1.5, blurred, -0.5, 0)
```
- Preserves (H, W, 3) BGR `uint8` invariant.
- Average CPU latency: **~12 ms** on a 2000x2000 image (< 100 ms budget).

### 6. Mobile Error Response Contract
For severely blurry images, `VisionStudio.enhance()` safely returns:
```json
{
  "contract_version": "1.0",
  "status": "error",
  "processed_image_path": null,
  "metadata": {},
  "errors": [
    {
      "code": "IMAGE_TOO_BLURRY",
      "message": "Your photo looks a bit blurry! Try holding your camera steady or tapping on the product to focus, then snap another photo.",
      "stage": "validate"
    }
  ]
}
```

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

---

## Phase 4 Lighting Correction Specifications

### 1. Stage Signature & Data Contract
#### `correct_lighting` (`vision_studio/pipeline/lighting.py`)
```python
@dataclass
class LightingResult:
    image: np.ndarray             # np.ndarray, dtype=uint8, shape=(H, W, 3), BGR format
    metadata: dict[str, Any]      # white_balance_gains, gamma_applied, mean_luminance_before/after, duration_ms

def correct_lighting(
    image_bgr: np.ndarray,
    mask: np.ndarray | None = None,
    cfg: Any = None,
) -> LightingResult:
    """Correct lighting, white balance, and contrast on masked foreground pixels."""
```

### 2. Correction Pipeline & Parameter Order
1. **Masked White Balance (Gray-World Assumption)**:
   - Evaluated on foreground pixels (`mask > 0`).
   - Mean channel intensities: $(\mu_B, \mu_G, \mu_R)$.
   - Gray target: $\mu_{gray} = \frac{\mu_B + \mu_G + \mu_R}{3.0}$.
   - Channel gains: $g_c = \frac{\mu_{gray}}{\mu_c}$, clamped strictly to $[0.6, 1.8]$.
   - Applied to BGR channels in float32 and clipped to $[0, 255]$.
2. **Masked Auto-Gamma Correction**:
   - Perceived luminance $Y = 0.114 B + 0.587 G + 0.299 R$ measured on WB-corrected foreground.
   - Normalized luminance $L_{norm} = \text{clip}(Y / 255.0, 0.01, 0.99)$; target mid-gray $T_{norm} = 128.0 / 255.0 \approx 0.502$.
   - Gamma exponent: $\gamma = \frac{\ln(T_{norm})}{\ln(L_{norm})}$, clamped to $[0.5, 2.0]$.
   - Applied via 256-entry precomputed `cv2.LUT` table for near-instant CPU execution ($< 1$ ms).
3. **Shadow & Local Contrast Enhancement (LAB CLAHE)**:
   - Converted to LAB color space.
   - Applied `cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))` strictly to the L (luminance) channel to avoid chromatic distortion.
   - Converted back from LAB to BGR.
4. **Masked Reconstruction & Background Preservation**:
   - Background pixels where `mask == 0` are bitwise preserved from the input BGR image:
     ```python
     final_image = image_bgr.copy()
     final_image[mask_bool] = corrected_bgr[mask_bool]
     ```
   - If mask is `None` or all zeros, the stage falls back to correcting the entire image safely without crashing (`fallback_full_image = True`).

### 3. Clamp Ranges & Safeguards
- **White Balance Gain Clamp**: $[0.6, 1.8]$ prevents extreme color shifts or blown highlights on artisan crafts with dominant natural dye hues (e.g. indigo or madder red).
- **Auto-Gamma Clamp**: $[0.5, 2.0]$ prevents excessive grain amplification in deep shadows or washed-out highlights.
- **Invariant**: Input and output are strictly 3-channel `uint8` BGR with identical shape `(H, W, 3)`. Background pixels (`mask == 0`) remain 100% bitwise unchanged.

### 4. Empirical Test Measurements (Before / After)
| Test Fixture / Condition | Mean Luminance (Before) | Mean Luminance (After) | WB Gains $[R, G, B]$ | Gamma $\gamma$ | Result |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `dark_yellow_fixture` (Dark, yellow-tinted) | **56.63** | **137.91** | $[0.6000, 0.8202, 1.8000]$ | **0.5000** | Brighter & neutral |
| `product_textile.jpg` (Fast rembg output) | **122.03** | **131.12** | $[0.6515, 1.1221, 1.7423]$ | **0.8718** | Balanced highlights |
| `neutral_mid_gray` (128 mid-gray) | **128.00** | **128.00** | $[1.0000, 1.0000, 1.0000]$ | **1.0000** | Preserved (no distortion) |

---

## HANDOFF -> PHASE 5 (Composition, Background Placement, and Export)

### 1. Available Artifacts & Stage Outputs
From Phase 4, `VisionStudio.enhance()` produces:
- `current_image` (BGR `uint8`): Lighting-corrected foreground with background pixels zeroed out (or original).
- `bg_result.mask` (Grayscale `uint8`): Segmentation alpha mask with `(H, W)` dimensions.
- `bg_result.bbox`: Subject bounding box `(x, y, w, h)`.
- `metadata["lighting"]`: Dictionary with `white_balance_gains`, `gamma_applied`, `mean_luminance_before`, `mean_luminance_after`, `duration_ms`.

### 2. Phase 5 Objectives
1. **Composition & Canvas Placement**:
   - Place extracted, lighting-corrected subject onto standard e-commerce background (e.g. solid white `#FFFFFF` or subtle neutral studio backdrop) sized to `EnhanceOptions.output_size` (default `1000x1000`).
   - Center and scale subject with standard margins (e.g. 80–85% canvas occupancy based on `bbox`).
2. **Soft Shadow Generation**:
   - Render a subtle, natural contact shadow beneath the product base for photorealistic grounding.
3. **Export & Format Optimization**:
   - Final JPEG/PNG export with configurable compression quality and metadata preservation.


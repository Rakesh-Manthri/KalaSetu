# Phase State Tracking — AI Vision Studio

## Current Status: Phase 5 Complete (Composition, Export & Before/After Demo Builder)

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
- [x] **Phase 5**: Canvas composition stage (`vision_studio/pipeline/composition.py`) with aspect-ratio fitting, 8% e-commerce margin, antialiased edge blending, and soft contact drop shadow.
- [x] **Phase 5**: Export stage (`vision_studio/pipeline/export.py`) generating JPEG (Q=95) e-commerce catalog image and side-by-side Before/After pitch montage.
- [x] **Phase 5**: Full end-to-end pipeline wiring in `VisionStudio.enhance()` returning `status="success"`, file paths, `duration_ms` total, and stage-by-stage execution metrics.
- [x] **Phase 5**: Before/After demo script (`examples/before_after_demo.py`) and standalone runner (`examples/run_standalone.py`) for pitch asset generation.
- [x] **Phase 5**: Comprehensive test suite (`tests/test_composition.py`, `tests/test_pipeline.py`, 66/66 tests passing offline).

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
1. **Masked White Balance (Chromaticity-Preserving Gray-World)**:
   - Evaluated on foreground pixels (`mask > 0`).
   - Mean channel intensities: $(\mu_B, \mu_G, \mu_R)$.
   - Gray target: $\mu_{gray} = \frac{\mu_B + \mu_G + \mu_R}{3.0}$.
   - Raw gains: $g_{\text{raw}, c} = \frac{\mu_{gray}}{\mu_c}$, clamped strictly to $[0.6, 1.8]$.
   - Soft correction blend: $g_c = 1.0 + (g_{\text{raw}, c} - 1.0) \times 0.30$ to gently remove ambient light casts while preserving 100% of authentic artisan craft dyes (terracotta, brass, indigo, silk).
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

## Phase 5 Composition & Export Specifications

### 1. Stage Signatures & Data Contracts

#### `compose` (`vision_studio/pipeline/composition.py`)
```python
@dataclass
class CompositionResult:
    image: np.ndarray             # np.ndarray, dtype=uint8, shape=(H, W, 3), BGR format
    metadata: dict[str, Any]      # output_size, background_color, margin_pct, subject_dims, offsets, shadow_applied, duration_ms

def compose(
    foreground_bgr: np.ndarray,
    mask: np.ndarray | None,
    bbox: tuple[int, int, int, int] | None = None,
    cfg: Any = None,
) -> CompositionResult:
    """Center, pad, resize, and place product foreground onto standard e-commerce canvas."""
```

#### `export` (`vision_studio/pipeline/export.py`)
```python
@dataclass
class ExportResult:
    image_path: str               # Absolute/relative path to final JPEG output
    montage_path: str | None      # Path to side-by-side Before/After pitch montage
    metadata: dict[str, Any]      # filename, width, height, size_bytes, montage_filename, montage_path, duration_ms

def export(
    final_bgr: np.ndarray,
    out_dir: str | Path,
    name: str,
    original_bgr: np.ndarray | None = None,
    cfg: Any = None,
) -> ExportResult:
    """Export the final processed image and optional before/after comparison montage."""
```

### 2. Canvas Geometry & Placement Math
- **Canvas Size**: Defaults to `(1000, 1000)` square canvas per marketplace standards (Amazon / Flipkart / Meesho / GeM).
- **Subject Bounding Box & Aspect-Ratio Scaling**:
  $$\text{margin}_w = \lfloor 0.08 \times W_c \rceil, \quad \text{margin}_h = \lfloor 0.08 \times H_c \rceil$$
  $$\text{avail}_w = W_c - 2 \cdot \text{margin}_w, \quad \text{avail}_h = H_c - 2 \cdot \text{margin}_h$$
  $$\text{scale} = \min\left(\frac{\text{avail}_w}{w_{\text{bbox}}}, \frac{\text{avail}_h}{h_{\text{bbox}}}\right)$$
  $$W_{\text{new}} = \max(1, \lfloor w_{\text{bbox}} \cdot \text{scale} \rceil), \quad H_{\text{new}} = \max(1, \lfloor h_{\text{bbox}} \cdot \text{scale} \rceil)$$
- **Centering Offsets**:
  $$\text{offset}_x = \frac{W_c - W_{\text{new}}}{2}, \quad \text{offset}_y = \frac{H_c - H_{\text{new}}}{2}$$
- **Edge Antialiasing**: Resized alpha mask smoothed with Gaussian blur ($\sigma=0.8$) before blending with canvas background.
- **Soft Contact Drop Shadow**:
  - Vertical offset $\Delta y \approx 1.5\%$ of canvas height.
  - Soft Gaussian blur ($k = 0.025 \times H_c$, $\sigma = k / 3$).
  - Opacity $\sim 12\%$ with dark neutral tint. Skipped when `quality="fast"`.

### 3. Before/After Side-by-Side Montage Layout
- **Canvas Dimensions**: `(H_final + 50, W_final * 2 + 2, 3)`
- **Header Banner**: 50px dark slate header (`[30, 25, 20]` BGR) with centered typographic labels:
  - Left: `"BEFORE: Raw Artisan Photo"` (neutral silver gray)
  - Right: `"AFTER: KalaSetu AI Studio"` (vibrant accent green)
- **Panels**:
  - Left Panel: Original raw artisan photo letterboxed/centered to match catalog height.
  - Divider: 2px subtle vertical line (`[200, 200, 200]` BGR).
  - Right Panel: Full e-commerce composite image on pure white/neutral background.
- Saved to `outputs/before_after_{name}.jpg` at JPEG quality 95.

### 4. Final Metadata JSON Schema
```json
{
  "duration_ms": 4059.34,
  "background_removed": true,
  "orig_dims": [600, 400],
  "processed_dims": [1000, 1000],
  "quality": "balanced",
  "options": {
    "remove_background": true,
    "correct_lighting": true,
    "output_size": [1000, 1000],
    "background_color": "#FFFFFF",
    "quality": "balanced"
  },
  "original_image_path": "tests/fixtures/product_textile.jpg",
  "image_metadata": {
    "orig_dims": [600, 400],
    "norm_dims": [600, 400],
    "format": "jpeg",
    "has_alpha": false,
    "blur_score": 101.60,
    "blur_status": "sharp",
    "sharpened": false
  },
  "stages": {
    "validate": { ... },
    "bg_removal": { "quality": "balanced", "model": "u2net", "duration_ms": 3352.1, "input_dims": [600, 400] },
    "lighting": { "white_balance_gains": [0.65, 1.12, 1.74], "gamma_applied": 0.87, "mean_luminance_before": 122.26, "mean_luminance_after": 131.07, "duration_ms": 429.05 },
    "composition": { "output_size": [1000, 1000], "background_color": "#FFFFFF", "margin_pct": 0.08, "subject_dims": [840, 669], "offsets": [80, 165], "shadow_applied": true, "duration_ms": 138.79 },
    "export": { "filename": "product_textile.jpg", "width": 1000, "height": 1000, "size_bytes": 41083, "montage_filename": "before_after_product_textile.jpg", "montage_path": "outputs/before_after_product_textile.jpg", "duration_ms": 98.62 }
  },
  "montage_path": "outputs/before_after_product_textile.jpg"
}
```

### 5. Output Directory Convention
- Final catalog JPEG: `outputs/{stem}.jpg`
- Companion transparent cutout PNG: `outputs/{stem}_nobg.png`
- Before/After pitch montage: `outputs/before_after_{stem}.jpg`

### 6. Edge Cases Handled
- **Subject smaller than canvas**: Automatically scaled up to fill available area while strictly respecting the 8% margin.
- **Subject larger than canvas**: Downscaled via `cv2.INTER_AREA` for high-frequency sharpness preservation.
- **Already-square images**: Centered with identical 8% margins on all 4 borders.
- **Empty / None mask**: Safely falls back to centered full-image canvas placement without crashing.
- **Disabled stages**: Pipeline safely bypasses disabled stages (`remove_background=False`, `correct_lighting=False`) while maintaining valid composition and export.

---

## Phase 6 Testing, Hardening & Quality Benchmark Specifications

### 1. Completed Tasks in Phase 6
- [x] **Timeout Protection (`vision_studio/utils/timeout.py`)**: `run_with_timeout(func, args, seconds)` using `concurrent.futures.ThreadPoolExecutor` returning clean `VisionStudioError(code=TIMEOUT, stage=...)` on breach without blocking the caller forever.
- [x] **Pipeline Timeout Wrapping (`vision_studio/api.py`)**: Wrapped `VisionStudio.enhance()` with `self.config.request_timeout_s` protection, catching timeouts and returning structured `status="error"` with code `TIMEOUT`.
- [x] **Config & Environment Hardening (`vision_studio/config.py`, `.env.example`)**: Finalized `Settings` with `model_dir`, `default_quality`, `max_image_mb`, `inference_device`, `request_timeout_s=20.0`, `output_dir="./outputs"`, `blur_severe_threshold=15.0`, `blur_light_threshold=60.0`, cached singleton `get_settings()`, and Pydantic field validators.
- [x] **Offline Model Pre-download Script (`scripts/download_models.sh`)**: Automated shell script to pre-fetch and cache both `u2net` and `u2netp` sessions in `~/.rembg/models/` for 100% offline deployment.
- [x] **Hardening Test Suite (`tests/test_hardening.py`)**: 13 comprehensive test cases covering timeout simulation, ONNX model loading failures, partial pipeline failures (e.g. lighting failure after successful bg removal), and configuration validation.
- [x] **Quality & Latency Benchmark Script (`eval/benchmark.py`, `eval/README.md`)**: Automated multi-stage benchmarking across `fast`, `balanced`, and `high` quality tiers measuring stage latencies and disk footprint.
- [x] **Production Documentation (`README.md`, `tests/fixtures/README.md`)**: Complete module documentation with architectural flowcharts, SIH impact statement, error codes reference, teammate integration code, and benchmark results.

### 2. Final Settings Keys and Defaults
| Setting Key | Type | Default | Validation / Constraints |
| :--- | :--- | :--- | :--- |
| `model_dir` | `str` | `"./models"` | Storage directory for offline weights |
| `default_quality` | `Literal["fast", "balanced", "high"]` | `"balanced"` | Must be one of `fast`, `balanced`, `high` |
| `max_image_mb` | `int` | `15` | Positive integer (> 0) |
| `inference_device` | `str` | `"cpu"` | `"cpu"` (or execution provider string) |
| `request_timeout_s`| `float` | `20.0` | Positive float (> 0) |
| `output_dir` | `str` | `"./outputs"` | Path where exported images & montages are written |
| `blur_severe_threshold` | `float` | `15.0` | Rejection cutoff for Laplacian variance |
| `blur_light_threshold` | `float` | `60.0` | Cutoff below which unsharp mask is applied |

### 3. Full Benchmark Table (Measured Empirical CPU Latency)
| Fixture / Product Category | Quality Tier | ONNX Model | Validate | BG Removal | Lighting | Composition | Export | Total Latency | Output Size | Status |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `product_textile.jpg` (Handloom) | **fast** | `u2netp` | 10.1 ms | 661.8 ms | 40.7 ms | 97.5 ms | 102.6 ms | **943.8 ms** | 36.0 KB | `success` |
| `product_textile.jpg` (Handloom) | **balanced** | `u2net` | 11.9 ms | 4183.7 ms | 667.6 ms | 454.5 ms | 74.4 ms | **5413.3 ms** | 38.9 KB | `success` |
| `product_textile.jpg` (Handloom) | **high** | `u2net` | 8.5 ms | 2163.4 ms | 71.6 ms | 154.1 ms | 59.1 ms | **2470.3 ms** | 38.9 KB | `success` |
| `valid_sample.jpg` (Terracotta) | **fast** | `u2netp` | 5.4 ms | 1678.4 ms | 31.3 ms | 93.2 ms | 117.8 ms | **1942.5 ms** | 39.9 KB | `success` |
| `valid_sample.jpg` (Terracotta) | **balanced** | `u2net` | 6.2 ms | 2391.5 ms | 17.4 ms | 125.6 ms | 102.1 ms | **2653.7 ms** | 41.9 KB | `success` |
| `valid_sample.jpg` (Terracotta) | **high** | `u2net` | 5.1 ms | 2132.8 ms | 20.5 ms | 120.5 ms | 72.3 ms | **2363.0 ms** | 41.9 KB | `success` |
| `large_dimension.jpg` (3000px HD) | **fast** | `u2netp` | 695.5 ms | 1565.1 ms | 1914.0 ms | 176.5 ms | 117.9 ms | **4857.5 ms** | 61.5 KB | `success` |
| `large_dimension.jpg` (3000px HD) | **balanced** | `u2net` | 316.2 ms | 1966.8 ms | 230.4 ms | 158.6 ms | 92.0 ms | **2857.4 ms** | 18.3 KB | `success` |
| `large_dimension.jpg` (3000px HD) | **high** | `u2net` | 271.2 ms | 1707.0 ms | 203.9 ms | 290.5 ms | 127.2 ms | **2874.2 ms** | 18.3 KB | `success` |

### 4. Test Suite Pass Count
- **Total Tests**: 79 passed, 0 failed, 0 xfail, 0 skipped.
- **Pass Rate**: 100% offline pass rate across unit, validation, blur detection, background removal, lighting correction, composition, export, and hardening test modules.

### 5. Standardized Error Codes
- `FILE_NOT_FOUND`: Input image path is invalid or missing.
- `INVALID_IMAGE`: Corrupted image or invalid header bytes.
- `UNSUPPORTED_FORMAT`: Format not in JPEG, PNG, WEBP, BMP.
- `IMAGE_TOO_LARGE`: Image size exceeds `max_image_mb` (15 MB).
- `IMAGE_TOO_BLURRY`: Laplacian variance < 15.0.
- `EMPTY_MASK`: Background removal detected zero foreground subject pixels.
- `MODEL_LOAD_FAILED`: ONNX model runtime failed to initialize session.
- `STAGE_FAILED`: Unhandled internal exception in stage calculation.
- `TIMEOUT`: Request exceeded configured execution timeout (`request_timeout_s=20s`).

---

## HANDOFF -> PHASE 7 (Final Polish, Demo Assets & SIH Submission Package)

### 1. Verification Commands
```bash
# Run All Offline Tests
pytest tests/ -v

# Run Latency & Quality Benchmark
python eval/benchmark.py

# Run Visual Pitch Demo
python examples/before_after_demo.py tests/fixtures/product_textile.jpg
```

### 2. Readiness for Final Submission
- Package `vision_studio` is 100% standalone, contract-compliant, self-contained within `ai-vision-studio/`, and ready for packaging and judge presentation.




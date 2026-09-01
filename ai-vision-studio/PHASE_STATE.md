# Phase State Tracking — AI Vision Studio

## Current Status: Phase 1 Complete (Skeleton, Contract & One-Tap Stub)

### Completed Tasks
- [x] Package setup (`pyproject.toml`, `.gitignore`, `.env.example`)
- [x] Strict public API contracts (`EnhanceRequest`, `EnhanceResponse`, `EnhanceOptions` in `contracts.py`)
- [x] Pydantic-settings configuration (`config.py`)
- [x] Main entry point `VisionStudio` with stub `enhance()` implementation (`api.py`)
- [x] Modular pipeline stubs (`validate`, `bg_removal`, `lighting`, `composition`, `export`)
- [x] Backend model interfaces and `RembgBackend` stub (`models/base.py`, `models/rembg_backend.py`)
- [x] Error handling & logger utilities (`utils/errors.py`, `utils/logging.py`)
- [x] CLI entrypoint (`cli.py`) and standalone runner (`examples/run_standalone.py`)
- [x] Smoke test suite (`tests/test_smoke.py`)

---

## HANDOFF -> PHASE 2

### Package Info & Location
- **Root Folder**: `ai-vision-studio/`
- **Package Name**: `vision-studio` (module `vision_studio`)
- **Primary Entry Point**: `vision_studio.VisionStudio.enhance(request: EnhanceRequest | dict) -> EnhanceResponse`

### Finalized Public Contracts (`vision_studio/contracts.py`)
```python
from pydantic import BaseModel
from typing import Literal

class EnhanceOptions(BaseModel):
    remove_background: bool = True
    correct_lighting: bool = True
    output_size: tuple[int, int] = (1000, 1000)
    background_color: str = "#FFFFFF"
    quality: Literal["fast", "balanced", "high"] = "balanced"

class EnhanceRequest(BaseModel):
    contract_version: str = "1.0"
    image_path: str
    options: EnhanceOptions = EnhanceOptions()

class EnhanceResponse(BaseModel):
    contract_version: str = "1.0"
    status: Literal["success", "partial", "error"]
    processed_image_path: str | None = None
    metadata: dict = {}
    errors: list[dict] = []
```

### Stack & Locked Dependencies
- Python 3.11+
- `opencv-python-headless >= 4.9`
- `pillow >= 10.0`
- `rembg >= 2.0`
- `onnxruntime >= 1.17`
- `pydantic >= 2.5`
- `pydantic-settings >= 2.1`
- `numpy >= 1.26`
- `pytest >= 8.0` (dev)

### Pipeline Status
- All pipeline stages (`validate`, `bg_removal`, `lighting`, `composition`, `export`) are pure function passthrough stubs.
- `models/rembg_backend.py` defines `RembgBackend(ModelBackend)` and raises `NotImplementedError` for `load()` and `predict()`.

### How to Run & Verify
1. Install editable package:
   ```bash
   cd ai-vision-studio
   pip install -e ".[dev]"
   ```
2. Run standalone stub script:
   ```bash
   python examples/run_standalone.py fake.jpg
   ```
3. Run smoke test suite:
   ```bash
   pytest tests/test_smoke.py -v
   ```

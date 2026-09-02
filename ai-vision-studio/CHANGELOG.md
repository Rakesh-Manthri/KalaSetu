# Changelog

All notable changes to the `vision-studio` module will be documented in this file.

## [1.1.0] - 2026-09-02
### Added
- Asynchronous FastAPI service wrapper in `vision_studio/service.py` with `GET /health` and `POST /enhance` endpoints.
- Support for both JSON body payloads and multipart/form-data image file uploads.
- Threadpool offloading (`asyncio.get_running_loop().run_in_executor`) to keep the ASGI event loop unblocked during CPU-bound inference.
- CORS middleware enabled for seamless mobile and web frontend integration.
- Production `Dockerfile` with Python 3.11-slim, headless OpenCV dependencies, and pre-warmed U2-Net/U2-Netp weights.
- Client integration demo script (`examples/client_demo.py`) simulating mobile application calls against the HTTP backend.
- Comprehensive system architecture documentation with Mermaid diagrams (`docs/ARCHITECTURE.md`).
- Problem statement impact and quantitative benchmark report (`docs/IMPACT.md`).
- Automated service test suite (`tests/test_service.py`).
### Changed
- Extended `pyproject.toml` with optional `[project.optional-dependencies] service` for FastAPI and Uvicorn.
- Consolidated final integration handoff documentation in `PHASE_STATE.md` and `README.md`.

## [1.0.0] - 2026-09-02
### Added
- Complete 5-stage deterministic enhancement pipeline: Validate -> Background Removal -> Lighting Correction -> Composition -> Export.
- Background removal with session caching supporting `u2net` and `u2netp` ONNX backends.
- Classical lighting correction: Mask-aware CLAHE, Gray-World White Balance, and Adaptive Gamma correction.
- Canvas composition: Aspect-preserving 1:1 square canvas fitting (75-85% subject coverage), configurable background color, and realistic drop shadow.
- Progressive JPEG compression (<=500 KB target) and side-by-side verification montage generation.
- Laplacian blur detection with dual-tier thresholds (severe error vs. light warning).
- Robust timeout handling and error recovery with `run_with_timeout`.
- Latency and quality benchmark suite in `eval/benchmark.py`.

## [0.2.0] - 2026-09-02
### Added
- Image I/O utility (`vision_studio/utils/image_io.py`) with `load_image`, `save_image`, and `downscale_long_edge`.
- Real input validation pipeline stage (`vision_studio/pipeline/validate.py`).
- Standard error code constants and `make_error()` helper (`vision_studio/utils/errors.py`).
- Comprehensive test fixture suite in `tests/fixtures/` and `tests/conftest.py`.
- Full validation test suite `tests/test_validation.py`.
### Changed
- `VisionStudio.enhance()` now validates input paths and files first, returning clean error responses on invalid input.
- `tests/test_smoke.py` updated to verify Phase 2 validation error handling.

## [0.1.0] - 2026-09-02
### Added
- v1.0 — initial contract
- Core contracts: `EnhanceRequest`, `EnhanceResponse`, `EnhanceOptions`
- `VisionStudio` main API class with Phase 1 stub execution
- Configuration management with `pydantic-settings`
- Pipeline stub modules (`validate`, `bg_removal`, `lighting`, `composition`, `export`)
- Model backend interface and rembg stub
- Error handling models and logging utility
- CLI stub and standalone example script
- Smoke test suite for contract verification

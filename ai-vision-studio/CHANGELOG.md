# Changelog

All notable changes to the `vision-studio` module will be documented in this file.

## [0.2.0] - 2026-09-02
### Added
- Image I/O utility (`vision_studio/utils/image_io.py`) with `load_image`, `save_image`, and `downscale_long_edge`
- Real input validation pipeline stage (`vision_studio/pipeline/validate.py`)
- Standard error code constants and `make_error()` helper (`vision_studio/utils/errors.py`)
- Comprehensive test fixture suite in `tests/fixtures/` and `tests/conftest.py`
- Full validation test suite `tests/test_validation.py`
### Changed
- `VisionStudio.enhance()` now validates input paths and files first, returning clean error responses on invalid input
- `tests/test_smoke.py` updated to verify Phase 2 validation error handling

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


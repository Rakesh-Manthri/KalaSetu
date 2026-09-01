# AI Vision Studio (`vision-studio`)

AI Image Enhancer & Studio module for the **AI-Driven Market Linkage & Smart Cataloging Mobile Application for Marginalized Artisans** (Smart India Hackathon PS 26090).

Provides automated background removal, lighting correction, and e-commerce standard formatting for artisan handicrafts and textiles.

## Quick Start (Phase 1)

### Installation
```bash
cd ai-vision-studio
pip install -e .
```

For development (including testing):
```bash
pip install -e ".[dev]"
```

### Running Standalone Example
```bash
python examples/run_standalone.py path/to/sample.jpg
```

### Running Tests
```bash
pytest tests/test_smoke.py -v
```

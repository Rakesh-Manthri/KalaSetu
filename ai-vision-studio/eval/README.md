# AI Vision Studio — Evaluation & Quality Benchmark

## Overview
This directory contains automated quality, edge preservation, and latency evaluation tools for the **AI Vision Studio** module (SIH PS 26090: *AI-Driven Market Linkage & Smart Cataloging Mobile Application for Marginalized Artisans*).

## Evaluation Methodology
The benchmark suite evaluates:
1. **End-to-End Latency**: Measured on 100% offline CPU execution per pipeline stage (`validate`, `bg_removal`, `lighting`, `composition`, `export`).
2. **Model Profiles**:
   - `fast` (Target 640px, `u2netp` model): Optimized for real-time mobile upload previews (<3s target).
   - `balanced` (Target 768px, `u2net` model): Default e-commerce production tier (<6s target).
   - `high` (Target 1024px, `u2net` model): High-detail cataloging for intricate artisan crafts and fine textiles (<12s target).
3. **Stage Breakdown**:
   - `validate`: EXIF normalization, dimension check, and Laplacian blur detection (<100 ms).
   - `bg_removal`: ONNX Runtime U2-Net/U2-Netp salient foreground segmentation.
   - `lighting`: Masked Gray-World white balance, auto-gamma correction, and LAB CLAHE contrast enhancement (<500 ms).
   - `composition`: Centering, 8% standard e-commerce margin, antialiased alpha blending, and soft drop shadow (<150 ms).
   - `export`: E-commerce JPEG encoding (Q=95) and side-by-side Before/After pitch montage (<100 ms).

## Running the Benchmark
Execute the benchmark script from the package root:
```bash
python eval/benchmark.py
```

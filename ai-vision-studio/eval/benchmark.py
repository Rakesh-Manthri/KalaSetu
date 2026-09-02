"""AI Vision Studio Quality & Latency Benchmark Script (SIH PS 26090).

Evaluates latency across all stages (validate, bg_removal, lighting, composition, export)
for all quality profiles ('fast', 'balanced', 'high') across multiple product categories.

Usage:
    # Run default test suite fixtures:
    python eval/benchmark.py

    # Run on your own custom test image:
    python eval/benchmark.py "path/to/your_image.jpg"
"""

import sys
import time
from pathlib import Path
import cv2
import numpy as np

# Ensure vision_studio can be imported
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from vision_studio import EnhanceOptions, EnhanceRequest, VisionStudio


def ensure_fixtures(fixtures_dir: Path) -> list[Path]:
    """Ensure standard test fixtures exist or create synthetic ones."""
    fixtures_dir.mkdir(parents=True, exist_ok=True)
    fixtures: list[Path] = []

    # 1. product_textile.jpg (Textile / Handloom)
    f1 = fixtures_dir / "product_textile.jpg"
    if not f1.exists():
        arr = np.full((400, 600, 3), 220, dtype=np.uint8)
        arr[80:320, 100:500] = [30, 40, 180]  # rich crimson textile
        cv2.circle(arr, (300, 200), 50, (20, 160, 220), -1)  # gold motif
        cv2.imwrite(str(f1), arr, [cv2.IMWRITE_JPEG_QUALITY, 95])
    fixtures.append(f1)

    # 2. valid_sample.jpg (Terracotta / Pottery)
    f2 = fixtures_dir / "valid_sample.jpg"
    if not f2.exists():
        arr = np.full((300, 400, 3), 200, dtype=np.uint8)
        arr[50:250, 80:320] = [150, 100, 50]  # earthenware pot
        cv2.imwrite(str(f2), arr, [cv2.IMWRITE_JPEG_QUALITY, 95])
    fixtures.append(f2)

    # 3. large_dimension.jpg (High-Res Artisan Craft)
    f3 = fixtures_dir / "large_dimension.jpg"
    if not f3.exists():
        arr = np.full((2400, 3000, 3), 240, dtype=np.uint8)
        arr[600:1800, 800:2200] = [80, 120, 200]
        cv2.imwrite(str(f3), arr, [cv2.IMWRITE_JPEG_QUALITY, 85])
    fixtures.append(f3)

    return fixtures


def run_benchmark(custom_images: list[str] | None = None):
    """Run benchmark across fixtures or custom test images and quality tiers."""
    project_root = Path(__file__).resolve().parent.parent
    fixtures_dir = project_root / "tests" / "fixtures"

    if custom_images:
        fixtures = []
        for p in custom_images:
            path_obj = Path(p)
            if not path_obj.exists():
                print(f"ERROR: Image path not found: {p}", file=sys.stderr)
                sys.exit(1)
            fixtures.append(path_obj)
    else:
        fixtures = ensure_fixtures(fixtures_dir)

    print("=" * 110)
    print("AI VISION STUDIO — SIH PS 26090 LATENCY & QUALITY BENCHMARK")
    print("=" * 110)

    studio = VisionStudio()

    # Model warmup
    print("Warming up ONNX models (u2net / u2netp)...")
    warmup_req = EnhanceRequest(
        image_path=str(fixtures[0]),
        options=EnhanceOptions(quality="fast"),
    )
    studio.enhance(warmup_req)
    warmup_req_bal = EnhanceRequest(
        image_path=str(fixtures[0]),
        options=EnhanceOptions(quality="balanced"),
    )
    studio.enhance(warmup_req_bal)
    print("Warmup complete. Starting benchmark runs...\n")

    qualities = ["fast", "balanced", "high"]
    results = []

    for fixture in fixtures:
        for quality in qualities:
            req = EnhanceRequest(
                image_path=str(fixture),
                options=EnhanceOptions(
                    remove_background=True,
                    correct_lighting=True,
                    output_size=(1000, 1000),
                    background_color="#FFFFFF",
                    quality=quality,
                ),
            )

            # Measure end-to-end execution
            t0 = time.perf_counter()
            response = studio.enhance(req)
            wall_duration_ms = (time.perf_counter() - t0) * 1000

            status = response.status
            meta = response.metadata
            stages = meta.get("stages", {})

            val_ms = stages.get("validate", {}).get("duration_ms", 0.0) if isinstance(stages.get("validate"), dict) else 0.0
            bg_ms = stages.get("bg_removal", {}).get("duration_ms", 0.0) if stages.get("bg_removal") else 0.0
            lit_ms = stages.get("lighting", {}).get("duration_ms", 0.0) if stages.get("lighting") else 0.0
            comp_ms = stages.get("composition", {}).get("duration_ms", 0.0) if stages.get("composition") else 0.0
            exp_ms = stages.get("export", {}).get("duration_ms", 0.0) if stages.get("export") else 0.0
            model_used = stages.get("bg_removal", {}).get("model", "n/a") if stages.get("bg_removal") else "n/a"

            output_size_kb = 0.0
            if response.processed_image_path and Path(response.processed_image_path).exists():
                output_size_kb = Path(response.processed_image_path).stat().st_size / 1024.0

            results.append({
                "fixture": fixture.name,
                "quality": quality,
                "model": model_used,
                "validate_ms": val_ms,
                "bg_removal_ms": bg_ms,
                "lighting_ms": lit_ms,
                "composition_ms": comp_ms,
                "export_ms": exp_ms,
                "total_ms": meta.get("duration_ms", round(wall_duration_ms, 2)),
                "output_kb": round(output_size_kb, 1),
                "status": status,
            })

    # Print Markdown Table
    print("| Fixture / Test Image | Quality | Model | Validate | BG Removal | Lighting | Composition | Export | Total Latency | Output Size | Status |")
    print("| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |")
    for r in results:
        print(
            f"| `{r['fixture']}` | **{r['quality']}** | `{r['model']}` | "
            f"{r['validate_ms']:.1f} ms | {r['bg_removal_ms']:.1f} ms | {r['lighting_ms']:.1f} ms | "
            f"{r['composition_ms']:.1f} ms | {r['export_ms']:.1f} ms | **{r['total_ms']:.1f} ms** | "
            f"{r['output_kb']} KB | `{r['status']}` |"
        )

    print("\n" + "=" * 110)
    print("SUMMARY BY QUALITY PROFILE (Averages):")
    print("=" * 110)
    for q in qualities:
        q_results = [r for r in results if r["quality"] == q]
        avg_total = sum(r["total_ms"] for r in q_results) / len(q_results)
        avg_bg = sum(r["bg_removal_ms"] for r in q_results) / len(q_results)
        avg_light = sum(r["lighting_ms"] for r in q_results) / len(q_results)
        print(f"- Profile **{q.upper()}**: Avg Latency = {avg_total:.2f} ms (BG Removal: {avg_bg:.2f} ms, Lighting: {avg_light:.2f} ms)")

    return results


if __name__ == "__main__":
    custom_args = sys.argv[1:] if len(sys.argv) > 1 else None
    run_benchmark(custom_images=custom_args)

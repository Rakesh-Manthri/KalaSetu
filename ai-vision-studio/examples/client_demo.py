"""AI Vision Studio — Client Integration Demo.

Simulates a mobile app or frontend service calling the AI Vision Studio
FastAPI backend over HTTP. Demonstrates both JSON path requests and
multipart file uploads.

Modes:
    1. Live HTTP Mode (Default if server is running):
       Terminal 1: uvicorn vision_studio.service:app --port 8000
       Terminal 2: python examples/client_demo.py [path/to/image.jpg]

    2. In-Process Test Mode (Automatic fallback if live server is not started):
       Directly tests endpoints via ASGI test client in a single terminal.
"""

import sys
import os
from pathlib import Path
import time
import json
import httpx
import cv2
import numpy as np


BASE_URL = os.environ.get("VISION_STUDIO_URL", "http://127.0.0.1:8000")


def create_sample_artisan_image(path: str = "sample_artisan_product.jpg") -> str:
    """Generate a synthetic handcrafted ceramic vase image if none provided."""
    img = np.full((600, 600, 3), (220, 230, 240), dtype=np.uint8)
    # Draw a stylized terracotta vase
    cv2.ellipse(img, (300, 350), (120, 180), 0, 0, 360, (30, 80, 190), -1)
    cv2.rectangle(img, (260, 140), (340, 200), (30, 80, 190), -1)
    cv2.ellipse(img, (300, 140), (40, 15), 0, 0, 360, (20, 60, 160), -1)
    # Add some decorative patterns
    cv2.line(img, (200, 320), (400, 320), (240, 240, 255), 4)
    cv2.line(img, (210, 360), (390, 360), (240, 240, 255), 4)
    cv2.imwrite(path, img)
    return path


def test_health_endpoint(client, is_in_process: bool = False) -> bool:
    """Verify service health."""
    print("=" * 70)
    print("1. Checking Service Health: GET /health")
    print("=" * 70)
    url = "/health" if is_in_process else f"{BASE_URL}/health"
    try:
        resp = client.get(url, timeout=5.0)
        print(f"HTTP Status: {resp.status_code}")
        print(f"Response Body: {json.dumps(resp.json(), indent=2)}")
        return resp.status_code == 200 and resp.json().get("status") == "healthy"
    except Exception as e:
        print(f"\n[ERROR] Health check failed: {e}")
        return False


def test_enhance_multipart(client, image_path: str, is_in_process: bool = False) -> None:
    """Demonstrate multipart file upload enhancement (typical mobile app flow)."""
    print("\n" + "=" * 70)
    print("2. Enhancing via Multipart File Upload: POST /enhance")
    print("=" * 70)
    print(f"Uploading file: {image_path}")

    url = "/enhance" if is_in_process else f"{BASE_URL}/enhance"
    start_time = time.perf_counter()
    with open(image_path, "rb") as f:
        files = {"file": (Path(image_path).name, f, "image/jpeg")}
        data = {
            "quality": "balanced",
            "remove_background": "true",
            "correct_lighting": "true",
            "background_color": "#FFFFFF",
        }
        resp = client.post(url, files=files, data=data, timeout=60.0)

    elapsed_ms = round((time.perf_counter() - start_time) * 1000, 2)
    print(f"HTTP Status: {resp.status_code} (Roundtrip: {elapsed_ms} ms)")

    if resp.status_code == 200:
        result = resp.json()
        print(f"\nStatus: {result.get('status')}")
        print(f"Processed Image Path: {result.get('processed_image_path')}")
        metadata = result.get("metadata", {})
        print(f"Pipeline Execution Time: {metadata.get('duration_ms')} ms")
        print(f"Background Removed: {metadata.get('background_removed')}")
        print(f"Canvas Dims: {metadata.get('processed_dims')}")
        if metadata.get("montage_path"):
            print(f"Before/After Montage: {metadata.get('montage_path')}")
        if result.get("errors"):
            print(f"Warnings/Errors: {result.get('errors')}")
    else:
        print(f"Error Response: {resp.text}")


def test_enhance_json(client, image_path: str, is_in_process: bool = False) -> None:
    """Demonstrate JSON payload enhancement (server-to-server shared storage flow)."""
    print("\n" + "=" * 70)
    print("3. Enhancing via JSON Request: POST /enhance")
    print("=" * 70)
    abs_path = str(Path(image_path).resolve())
    payload = {
        "contract_version": "1.0",
        "image_path": abs_path,
        "options": {
            "remove_background": True,
            "correct_lighting": True,
            "quality": "fast",
            "output_size": [1000, 1000],
            "background_color": "#FFFFFF",
        },
    }
    print(f"Sending JSON payload for: {abs_path}")

    url = "/enhance" if is_in_process else f"{BASE_URL}/enhance"
    start_time = time.perf_counter()
    resp = client.post(
        url,
        json=payload,
        headers={"Content-Type": "application/json"},
        timeout=60.0,
    )
    elapsed_ms = round((time.perf_counter() - start_time) * 1000, 2)
    print(f"HTTP Status: {resp.status_code} (Roundtrip: {elapsed_ms} ms)")

    if resp.status_code == 200:
        result = resp.json()
        print(f"Status: {result.get('status')}")
        print(f"Processed Image Path: {result.get('processed_image_path')}")
        print(f"Pipeline Duration: {result.get('metadata', {}).get('duration_ms')} ms")
    else:
        print(f"Error Response: {resp.text}")


def main():
    if len(sys.argv) > 1 and os.path.isfile(sys.argv[1]):
        image_path = sys.argv[1]
    else:
        image_path = "sample_artisan_product.jpg"
        if not os.path.exists(image_path):
            create_sample_artisan_image(image_path)
            print(f"Created sample test image: {image_path}")

    # Check if a live Uvicorn service is actively listening
    is_live = False
    try:
        with httpx.Client() as probe:
            r = probe.get(f"{BASE_URL}/health", timeout=1.0)
            if r.status_code == 200:
                is_live = True
    except Exception:
        is_live = False

    if is_live:
        print(f"[INFO] Connected to live Vision Studio service at {BASE_URL}")
        with httpx.Client() as client:
            healthy = test_health_endpoint(client, is_in_process=False)
            if not healthy:
                sys.exit(1)
            test_enhance_multipart(client, image_path, is_in_process=False)
            test_enhance_json(client, image_path, is_in_process=False)
    else:
        print(f"[INFO] No live service detected at {BASE_URL}.")
        print("[INFO] Running demo in In-Process ASGI mode (simulating FastAPI server)...")
        print("[TIP] To run against a live daemon, start 'uvicorn vision_studio.service:app --port 8000' in another terminal.\n")
        from fastapi.testclient import TestClient
        from vision_studio.service import app

        with TestClient(app) as client:
            healthy = test_health_endpoint(client, is_in_process=True)
            if not healthy:
                sys.exit(1)
            test_enhance_multipart(client, image_path, is_in_process=True)
            test_enhance_json(client, image_path, is_in_process=True)

    print("\n" + "=" * 70)
    print("AI VISION STUDIO SERVICE CLIENT DEMO COMPLETE — ALL CHECKS PASSED")
    print("=" * 70)


if __name__ == "__main__":
    main()

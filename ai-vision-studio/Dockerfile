# AI Vision Studio — Docker Container
# SIH PS 26090: Smart Cataloging for Marginalized Artisans
# Python 3.11-slim CPU-optimized container

FROM python:3.11-slim

# Prevent python from writing pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    HOST=0.0.0.0 \
    U2NET_HOME=/root/.u2net

# Install minimal OS dependencies required for OpenCV headless and image processing
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependency specifications and project files
COPY pyproject.toml README.md /app/
COPY vision_studio /app/vision_studio

# Install package along with FastAPI, Uvicorn, and service dependencies
RUN pip install --no-cache-dir -e . \
    && pip install --no-cache-dir fastapi uvicorn[standard] httpx python-multipart

# RUN a warm-up and pre-download of U2-Net and U2-Netp weights during image build
# This ensures zero initial download delay on the first user inference request
RUN python -c "import rembg; rembg.new_session('u2netp'); rembg.new_session('u2net'); print('U2-Net weights pre-cached successfully')"

# Expose HTTP service port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Launch FastAPI application via Uvicorn
CMD ["uvicorn", "vision_studio.service:app", "--host", "0.0.0.0", "--port", "8000"]

"""
KalaSetu Python FastAPI Backend Server
Smart India Hackathon 2026 | Problem Statement 26090
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import voice, image, pricing, passport, orders

app = FastAPI(
    title="KalaSetu Backend API",
    description="AI-Driven Market Linkage & Smart Cataloging Backend Engine",
    version="1.0.0"
)

# Enable CORS for Flutter app & Web frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static output directory for enhanced product images & montages
from pathlib import Path
from fastapi.staticfiles import StaticFiles

outputs_candidates = [
    Path(__file__).resolve().parent.parent / "ai-vision-studio" / "outputs",
    Path("ai-vision-studio/outputs").resolve(),
    Path("../ai-vision-studio/outputs").resolve(),
]
outputs_dir = next((p for p in outputs_candidates if p.parent.exists()), outputs_candidates[0])
outputs_dir.mkdir(parents=True, exist_ok=True)
app.mount("/outputs", StaticFiles(directory=str(outputs_dir)), name="outputs")

# Include API Routers
app.include_router(voice.router)
app.include_router(image.router)
app.include_router(pricing.router)
app.include_router(passport.router)
app.include_router(orders.router)

@app.get("/")
async def root():
    return {
        "status": "online",
        "app": "KalaSetu Backend",
        "docs": "/docs",
        "version": "1.0.0"
    }

if __name__ == "__main__":
    import os
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=False)

# AI Vision Studio — Architecture & System Design

**Project**: Smart Cataloging & AI-Driven Market Linkage for Marginalized Artisans  
**Problem Statement**: SIH PS 26090  
**Module**: AI Vision & Image Studio (`ai-vision-studio`)  
**Lead Component**: Image enhancement, background removal, lighting correction, standard e-commerce canvas composition.

---

## 1. System Context & Team Integration

The `ai-vision-studio` module operates as an independent, decoupled component within the larger KalaSetu platform. It exposes both a direct Python API and an asynchronous HTTP service interface. External modules (Mobile App, Catalog Generator, Price Estimator) interface exclusively through contract-driven boundaries without direct code dependencies.

```mermaid
graph TB
    subgraph Client Layer ["Client / Presentation Layer"]
        MobileApp["📱 Mobile Artisan App<br/>(Flutter / React Native)"]
        WebAdmin["💻 Web Admin Portal<br/>(Marketplace Portal)"]
    end

    subgraph APILayer ["API & Service Boundary"]
        FastAPIService["⚡ FastAPI Service Wrapper<br/>(vision_studio.service)<br/>POST /enhance | GET /health"]
    end

    subgraph CoreModule ["AI Vision Studio (Our Module)"]
        VS["🎯 VisionStudio API<br/>(vision_studio.api.VisionStudio)"]
        
        subgraph Pipeline ["5-Stage Enhancement Pipeline"]
            S1["1. Validate & I/O<br/>Format, Dimension, Blur"]
            S2["2. Background Removal<br/>U2-Net / U2-Netp ONNX"]
            S3["3. Lighting Correction<br/>CLAHE, Auto-WB, Gamma"]
            S4["4. Canvas Composition<br/>Square 1:1, Margin, Shadow"]
            S5["5. Export & Montage<br/>JPEG (<=500KB), Before/After"]
        end
    end

    subgraph PeerModules ["Peer Team Modules (Decoupled Neighbors)"]
        CatalogGen["📦 Catalog & Description Gen<br/>(LLM / Text Module)"]
        PriceEst["🏷️ Fair Price Estimator<br/>(ML Pricing Model)"]
        VoiceAssist["🎙️ Multilingual Voice Assistant<br/>(Speech-to-Text)"]
    end

    MobileApp -->|"HTTP POST (Multipart/JSON)"| FastAPIService
    WebAdmin -->|"HTTP POST"| FastAPIService
    FastAPIService -->|"Python Contract Call"| VS
    VS --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    S4 --> S5

    MobileApp -.->|"Consumes Enhanced Photo"| CatalogGen
    MobileApp -.->|"Product Attributes"| PriceEst
    MobileApp -.->|"Artisan Voice Queries"| VoiceAssist

    classDef primary fill:#2563eb,stroke:#1d4ed8,stroke-width:2px,color:#fff;
    classDef service fill:#059669,stroke:#047857,stroke-width:2px,color:#fff;
    classDef peer fill:#6b7280,stroke:#4b5563,stroke-width:1px,stroke-dasharray: 5 5,color:#fff;
    
    class VS,S1,S2,S3,S4,S5 primary;
    class FastAPIService service;
    class CatalogGen,PriceEst,VoiceAssist peer;
```

---

## 2. Enhancement Pipeline Architecture

The processing pipeline guarantees deterministic transformations for handcrafted goods (textiles, pottery, jewelry, brassware) across 5 stages:

```mermaid
sequenceDiagram
    autonumber
    actor Client as Mobile App / Client
    participant Service as FastAPI Service (service.py)
    participant Core as VisionStudio (api.py)
    participant S1 as Stage 1: Validate
    participant S2 as Stage 2: BG Removal
    participant S3 as Stage 3: Lighting
    participant S4 as Stage 4: Composition
    participant S5 as Stage 5: Export

    Client->>Service: POST /enhance (Image binary or JSON path)
    Note over Service: Async Event Loop offloads to ThreadPoolExecutor
    Service->>Core: enhance(EnhanceRequest)
    
    Core->>S1: validate(image_path)
    Note over S1: Check file header, dimensions (<=3000px), Laplacian blur score
    S1-->>Core: Normalized BGR array, ImageMetadata
    
    Core->>S2: remove_background(image_array, options)
    Note over S2: Session caching (u2net / u2netp), alpha matte generation, contour bbox
    S2-->>Core: Foreground BGR, Alpha Mask, Bounding Box
    
    Core->>S3: correct_lighting(foreground_bgr, mask, raw_bgr)
    Note over S3: Mask-aware CLAHE, Gray-World White Balance, Adaptive Gamma
    S3-->>Core: Color-balanced foreground
    
    Core->>S4: compose(foreground, mask, bbox, options)
    Note over S4: Aspect-preserving scaling (75-85% canvas), centering, soft drop shadow
    S4-->>Core: Composed 1000x1000 Canvas Image
    
    Core->>S5: export(composed_image, raw_image, options)
    Note over S5: Progressive quality compression (<=500KB JPEG), Side-by-side Montage
    S5-->>Core: ExportResult (processed_image_path, montage_path)
    
    Core-->>Service: EnhanceResponse (status="success", metadata, errors)
    Service-->>Client: 200 OK JSON Response
```

---

## 3. Concurrency & Threading Model

Image processing operations (OpenCV matrix transforms, ONNX Runtime deep learning inference) are CPU-bound and synchronous. To prevent blocking the asynchronous FastAPI event loop:

- **Async Offloading**: Invocations of `studio.enhance(req)` are scheduled via `asyncio.get_running_loop().run_in_executor(None, studio.enhance, req)`.
- **Worker Threadpool**: Worker threads execute inference in parallel across available CPU cores.
- **Model Session Caching**: ONNX inference sessions for `u2net` and `u2netp` are instantiated as singletons per model type, preventing repeated weight allocation.
- **Timeout Protection**: The internal pipeline is wrapped in a configurable wall-clock timeout (`request_timeout_s=20.0`) using daemon worker execution.

---

## 4. API & Contract Boundary

The module boundary is strictly governed by [vision_studio/contracts.py](file:///c:/Users/Preetam/Desktop/KalaSetu/ai-vision-studio/vision_studio/contracts.py):

| Contract | Field | Type | Description |
|---|---|---|---|
| **EnhanceRequest** | `contract_version` | `str = "1.0"` | API contract schema version |
| | `image_path` | `str` | Absolute path to local image file |
| | `options` | `EnhanceOptions` | Fine-tuning knobs and quality profile |
| **EnhanceOptions** | `remove_background` | `bool = True` | Enable/disable AI background segmentation |
| | `correct_lighting` | `bool = True` | Enable/disable lighting and color normalization |
| | `output_size` | `tuple[int, int] = (1000, 1000)` | Final canvas width and height |
| | `background_color` | `str = "#FFFFFF"` | Target canvas background color (HEX) |
| | `quality` | `Literal["fast", "balanced", "high"]` | Processing profile selector |
| **EnhanceResponse** | `contract_version` | `str = "1.0"` | API contract schema version |
| | `status` | `Literal["success", "partial", "error"]` | Overall processing status |
| | `processed_image_path` | `str \| None` | Path to final enhanced product image |
| | `metadata` | `dict` | Execution metrics, stage latencies, image dims |
| | `errors` | `list[dict]` | Structured errors and warnings |

---

## 5. Deployment Modes

1. **Direct Python Import**: Embedded directly inside a desktop or backend Python script (`from vision_studio import VisionStudio, EnhanceRequest`).
2. **FastAPI Web Service**: Headless HTTP daemon (`uvicorn vision_studio.service:app --port 8000`) for mobile and cloud backend communication.
3. **Dockerized Microservice**: Containerized deployment (`docker run -p 8000:8000 vision-studio`) with pre-warmed weights.

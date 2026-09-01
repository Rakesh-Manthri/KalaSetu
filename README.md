<div align="center">

# 🪔 KalaSetu (कलासेतु)
### *AI-Driven Market Linkage & Smart Cataloging Mobile Application for Marginalized Artisans*

**Smart India Hackathon 2026** | **Problem Statement ID:** 26090  
**Theme:** Heritage & Culture | Software | **Team:** Out Of Scope  

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python)](https://www.python.org)
[![ONDC](https://img.shields.io/badge/ONDC-Network_Ready-0D50D5)](https://ondc.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*“Voice. Camera. Culture. Commerce.”*

---

</div>

## 📌 Problem & Core Concept

Marginalized rural artisans, weavers, and craft creators in India rely heavily on physical exhibitions and struggle to sell online due to:
1. **Low Digital Literacy**: Complex seller onboarding forms and portal UIs.
2. **Language Barriers**: E-commerce platforms primarily designed for English/Hindi.
3. **Lack of Cataloging Skills**: Inadequate product photography and descriptions.
4. **Unfair Pricing**: Intermediaries exploiting artisans who lack market benchmark transparency.

**KalaSetu** bridges this divide by turning any smartphone into an AI-powered e-commerce studio. An artisan simply speaks in their native regional language and photographs their craft; KalaSetu automates studio enhancement, bilingual story descriptions, dynamic fair pricing, and 1-tap publishing to the **Open Network for Digital Commerce (ONDC)**.

---

## ✨ Key Features

| Feature | Description |
| :--- | :--- |
| 🎙️ **Multilingual Voice-to-Catalog** | Speak freely in **7 Indian languages** (Hindi, Telugu, Tamil, Kannada, Marathi, Bengali, English). AI extracts materials, craft style, dimensions, and generates bilingual e-commerce listings. |
| 📸 **AI Image Studio** | Guided multi-angle photo capture with automated lighting calibration, contrast balancing, warm cream studio backdrop (`#F4EFE6`), and drop-shadow rendering. |
| 💰 **Smart Dynamic Fair Pricing** | Transparent pricing engine factoring material costs, labor hours, GI-tag heritage multipliers (+15%), and market demand across 3 strategy tiers (*Quick Sale*, *AI Recommended*, *Premium Craft*). |
| 📜 **Digital Craft Passport** | Verifiable digital provenance card with QR code authentication, GI certification numbers, and artisan craft heritage story. |
| 🌐 **ONDC Network Orders Hub** | Direct synchronization with ONDC buyer apps (Paytm Mall, Craftsvilla, GeM) with live order tracking (*New*, *In Transit*, *Completed*). |
| 🎨 **Artisan-First Heritage UI** | Floating pill navigation, large touch targets (56dp+), high-contrast Terracotta (`#EA580C`) and Trust Blue (`#1A56DB`) theme. |

---

## 🏗 System Architecture

```text
┌────────────────────────────────────────────────────────┐
│               Flutter Mobile Application               │
│                   (kalasetu_app)                       │
├────────────────────────────────────────────────────────┤
│  • Presentation: Riverpod + GoRouter + Material 3       │
│  • Multilingual: ARB Localizations (EN, HI, TE, TA...) │
│  • Storage: Hive CE (Offline-first drafts & cache)     │
│  • Media: Camera + Record + Audioplayers + QR Flutter  │
│  • API Client: Dio (Adaptive Base URL: Android/iOS)    │
└───────────────────────────┬────────────────────────────┘
                            │ HTTP / Multipart
                            ▼
┌────────────────────────────────────────────────────────┐
│            Python FastAPI Backend Server               │
│                      (backend)                         │
├────────────────────────────────────────────────────────┤
│  • /api/v1/voice: Speech-to-Metadata Extraction Engine │
│  • /api/v1/image: Pillow (PIL) Studio Photo Processing │
│  • /api/v1/pricing: Fair Price Calculation Engine      │
│  • /api/v1/passport: GI & Provenance Verification API   │
│  • /api/v1/orders: ONDC Network Order Synchronization  │
└────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```text
c:\Projects\KalaSetu\
├── .gitignore                   # Unified root gitignore for Python & Flutter
├── README.md                    # Project documentation & master guide
│
├── backend/                     # Python 3.12+ FastAPI Backend Engine
│   ├── main.py                  # Server entry point & CORS middleware
│   ├── requirements.txt         # FastAPI, Uvicorn, Pillow, Multipart, Pydantic
│   ├── routers/
│   │   ├── voice.py             # Voice transcription & AI metadata extraction
│   │   ├── image.py             # AI image studio enhancement
│   │   ├── pricing.py           # Smart pricing engine
│   │   ├── passport.py          # Digital Craft Passport & QR verification
│   │   └── orders.py            # ONDC and network orders hub
│   └── services/
│       ├── voice_extractor.py   # Multilingual regional parsing engine
│       ├── image_processor.py   # Studio background & shadow processing
│       └── pricing_engine.py    # Cost & GI multiplier calculations
│
└── kalasetu_app/                # Cross-Platform Flutter Mobile Application
    ├── pubspec.yaml             # Dependencies & asset declarations
    ├── lib/
    │   ├── main.dart            # App entry point with Hive initialization
    │   ├── app/                 # MaterialApp, GoRouter & Material 3 theme
    │   ├── core/
    │   │   ├── constants/       # AppColors (Terracotta & Blue), AppDimensions
    │   │   ├── models/          # ProductListing, Order, CraftPassport, Pricing
    │   │   └── widgets/         # KalaBottomNavBar, LanguageSelectorSheet
    │   ├── features/
    │   │   ├── home/            # Dashboard with metrics & recent activity
    │   │   ├── capture/         # Multi-angle camera & voice recorder
    │   │   ├── listing_preview/ # Before/After studio review & pricing
    │   │   ├── my_listings/     # 2-column Bento product catalog
    │   │   ├── orders/          # Orders hub with network badges
    │   │   └── profile/         # Artisan profile & GI authentication
    │   ├── l10n/                # ARB files for 7 Indian regional languages
    │   └── services/            # HttpApiClient (Dio) & MockApiClient
    └── assets/                  # Brand logo and product catalog images
```

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Flutter SDK** (v3.19+ / Dart 3.3+)
- **Python** (v3.10+ / v3.12 recommended)
- **Android Studio** (for Android Emulator) or physical device

---

### 2. Launch the Python Backend Server

```bash
# 1. Navigate to backend directory
cd backend

# 2. (Optional) Create virtual environment
python -m venv .venv
.venv\Scripts\activate     # On Windows PowerShell

# 3. Install dependencies
pip install -r requirements.txt

# 4. Start FastAPI server
uvicorn main:app --reload --port 8000
```
> 📖 **Interactive Swagger Docs:** Open `http://localhost:8000/docs` in your browser.

---

### 3. Launch the Flutter Mobile Application

```bash
# 1. Open a new terminal and navigate to app directory
cd kalasetu_app

# 2. Get Flutter dependencies
flutter pub get

# 3. Run the app on connected device / emulator
flutter run
```

---

## 🌐 Supported Regional Languages

| Language | Native Name | Code | Script |
| :--- | :--- | :--- | :--- |
| **English** *(Default)* | English | `en` | Latin |
| **Hindi** | हिंदी | `hi` | Devanagari |
| **Telugu** | తెలుగు | `te` | Telugu |
| **Tamil** | தமிழ் | `ta` | Tamil |
| **Kannada** | ಕನ್ನಡ | `kn` | Kannada |
| **Marathi** | मराठी | `mr` | Devanagari |
| **Bengali** | বাংলা | `bn` | Bengali |

---

## 🧪 Verification & Testing

```bash
# Backend Python Syntax Check
cd backend
python -m py_compile main.py

# Flutter Code Analysis
cd ../kalasetu_app
flutter analyze
```

---

## 👥 Team "Out Of Scope" (SIH 2026)
*Built with ❤️ for Indian artisans, weavers, and heritage creators.*

from fastapi import APIRouter

router = APIRouter(prefix="/api/v1/passport", tags=["Digital Craft Passport"])

PASSPORT_MAP = {
    "prod_001": {
        "listingId": "prod_001",
        "productName": "Handwoven Pochampally Ikat Pure Cotton Saree",
        "artisanName": "Lakshmi Devi",
        "location": "Pochampally, Yadadri Bhuvanagiri, Telangana",
        "giTag": "GI-IN-0043-POCHAMPALLY",
        "materials": ["100% Pure Mulberry Cotton", "Organic Plant Dyes"],
        "techniques": ["Traditional Geometric Ikat Weave", "Pit Loom Hand Weaving"],
        "verificationUrl": "https://karigarsetu.gov.in/verify?id=PASSPORT-KS-PROD_001",
        "imageUrl": "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80",
        "createdAt": "2026-08-20T10:00:00Z"
    },
    "prod_002": {
        "listingId": "prod_002",
        "productName": "Handcrafted Jaipur Blue Pottery Floral Vase",
        "artisanName": "Lakshmi Devi",
        "location": "Jaipur, Rajasthan",
        "giTag": "GI-IN-0002-JAIPUR-POTTERY",
        "materials": ["Quartz Powder", "Egyptian Paste", "Natural Cobalt Oxide"],
        "techniques": ["Clayless Molding", "Hand-painted Arabesque Motifs"],
        "verificationUrl": "https://karigarsetu.gov.in/verify?id=PASSPORT-KS-PROD_002",
        "imageUrl": "https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600&auto=format&fit=crop&q=80",
        "createdAt": "2026-08-22T10:00:00Z"
    }
}

@router.get("/{listing_id}")
async def get_craft_passport(listing_id: str):
    return PASSPORT_MAP.get(listing_id, PASSPORT_MAP["prod_001"])

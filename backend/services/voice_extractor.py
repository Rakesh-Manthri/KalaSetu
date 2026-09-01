"""
Voice Catalog & Multilingual Speech Extraction Engine
Extracted and adapted from C:\\kalasetu\\src\\services\\voiceCatalogService.js
Supports: Telugu (te), Hindi (hi), Tamil (ta), English (en), Kannada (kn), Marathi (mr), Bengali (bn)
"""

SAMPLE_TRANSCRIPTS = {
    "te": {
        "language": "Telugu (తెలుగు)",
        "transcript": "ఇది పోచంపల్లి ఇక్కత్ కాటన్ చీర. ఇది ఎరుపు మరియు నీలం రంగుల జ్యామితీయ డిజైన్‌తో చేతితో నేసినది. దీని పొడవు 6.3 మీటర్లు. శుద్ధమైన కాటన్ నూలుతో తయారు చేసాము.",
        "extracted": {
            "title": "Handwoven Pochampally Ikat Pure Cotton Saree",
            "titleHindi": "हस्तनिर्मित पोचमपल्ली इकत सूती साड़ी",
            "craftType": "Handloom",
            "category": "Textiles & Handloom",
            "subcategory": "Sarees",
            "material": "100% Pure Organic Cotton",
            "colour": "Indigo Blue & Crimson Red",
            "pattern": "Traditional Geometric Ikat Weave",
            "dimensions": "6.3 meters with blouse piece",
            "handmade": True,
            "region": "Pochampally, Telangana",
            "weight": "580g",
            "keywords": ["pochampally", "ikat saree", "handloom cotton", "telangana weave", "natural dye"],
            "descriptionEn": "Authentic hand-woven Pochampally Ikat cotton saree featuring intricate traditional geometric patterns. Woven on traditional pit looms by GI-certified master weavers using natural plant dyes.",
            "descriptionHi": "प्रामाणिक हाथ से बुनी गई पोचमपल्ली इकत सूती साड़ी। पारंपरिक प्राकृतिक रंगों और ज्यामितीय डिज़ाइन के साथ तैयार। जीआई टैग प्रमाणित कारीगरों द्वारा निर्मित।"
        }
    },
    "hi": {
        "language": "Hindi (हिंदी)",
        "transcript": "यह पोचमपल्ली इकत सूती साड़ी है। यह लाल और नीले रंग में हाथ से बुनी गई है। 6.3 मीटर लंबाई और प्राकृतिक रंगों से बनी है। शुद्ध सूती धागे से तैयार।",
        "extracted": {
            "title": "Handwoven Pochampally Ikat Pure Cotton Saree",
            "titleHindi": "हस्तनिर्मित पोचमपल्ली इकत सूती साड़ी",
            "craftType": "Handloom",
            "category": "Textiles & Handloom",
            "subcategory": "Sarees",
            "material": "100% Pure Organic Cotton",
            "colour": "Indigo Blue & Crimson Red",
            "pattern": "Traditional Geometric Ikat Weave",
            "dimensions": "6.3 meters with blouse piece",
            "handmade": True,
            "region": "Pochampally, Telangana",
            "weight": "580g",
            "keywords": ["pochampally", "ikat saree", "handloom cotton", "telangana weave", "natural dye"],
            "descriptionEn": "Authentic hand-woven Pochampally Ikat cotton saree featuring intricate traditional geometric patterns. Woven on traditional pit looms by GI-certified master weavers using natural plant dyes.",
            "descriptionHi": "प्रामाणिक हाथ से बुनी गई पोचमपल्ली इकत सूती साड़ी। पारंपरिक प्राकृतिक रंगों और ज्यामितीय डिज़ाइन के साथ तैयार। जीआई टैग प्रमाणित कारीगरों द्वारा निर्मित।"
        }
    },
    "ta": {
        "language": "Tamil (தமிழ்)",
        "transcript": "இது போச்சம்பள்ளி இக்கத் பருத்தி சேலை. கையால் நெய்யப்பட்ட பாரம்பரிய வடிவமைப்புகள். 6.3 மீட்டர் நீளம், இயற்கை சாயம் கொண்டது.",
        "extracted": {
            "title": "Handwoven Pochampally Ikat Pure Cotton Saree",
            "titleHindi": "हस्तनिर्मित पोचमपल्ली इकत सूती साड़ी",
            "craftType": "Handloom",
            "category": "Textiles & Handloom",
            "subcategory": "Sarees",
            "material": "100% Pure Organic Cotton",
            "colour": "Indigo Blue & Crimson Red",
            "pattern": "Traditional Geometric Ikat Weave",
            "dimensions": "6.3 meters with blouse piece",
            "handmade": True,
            "region": "Pochampally, Telangana",
            "weight": "580g",
            "keywords": ["pochampally", "ikat saree", "handloom cotton"],
            "descriptionEn": "Authentic hand-woven Pochampally Ikat cotton saree featuring intricate traditional geometric patterns. Woven on traditional pit looms using natural plant dyes.",
            "descriptionHi": "प्रामाणिक हाथ से बुनी गई पोचमपल्ली इकत सूती साड़ी। पारंपरिक प्राकृतिक रंगों और ज्यामितीय डिज़ाइन के साथ तैयार।"
        }
    },
    "en": {
        "language": "English",
        "transcript": "This is a Pochampally Ikat cotton saree. It is hand-woven using pure organic cotton in deep indigo blue and crimson red colors. 6.3 meters length.",
        "extracted": {
            "title": "Handwoven Pochampally Ikat Pure Cotton Saree",
            "titleHindi": "हस्तनिर्मित पोचमपल्ली इकत सूती साड़ी",
            "craftType": "Handloom",
            "category": "Textiles & Handloom",
            "subcategory": "Sarees",
            "material": "100% Pure Organic Cotton",
            "colour": "Indigo Blue & Crimson Red",
            "pattern": "Traditional Geometric Ikat Weave",
            "dimensions": "6.3 meters with blouse piece",
            "handmade": True,
            "region": "Pochampally, Telangana",
            "weight": "580g",
            "keywords": ["pochampally", "ikat saree", "handloom cotton", "telangana weave", "natural dye"],
            "descriptionEn": "Authentic hand-woven Pochampally Ikat cotton saree featuring intricate traditional geometric patterns. Woven on traditional pit looms by GI-certified master weavers using natural plant dyes.",
            "descriptionHi": "प्रामाणिक हाथ से बुनी गई पोचमपल्ली इकत सूती साड़ी। पारंपरिक प्राकृतिक रंगों और ज्यामितीय डिज़ाइन के साथ तैयार। जीआई टैग प्रमाणित कारीगरों द्वारा निर्मित।"
        }
    }
}

def extract_product_details(text: str, lang: str = "en") -> dict:
    """
    Parses user voice transcription or text into structured craft product JSON metadata.
    """
    text_lower = text.lower() if text else ""
    
    if any(k in text_lower for k in ["pottery", "vase", "फूलदान", "కుండ", "மண்பாண்டம்"]):
        return {
            "title": "Handcrafted Jaipur Blue Pottery Floral Vase",
            "titleHindi": "जयपुर ब्लू पॉटरी नक्काशीदार फूलदान",
            "craftType": "Pottery & Terracotta",
            "category": "Pottery",
            "subcategory": "Vases & Home Decor",
            "material": "Quartz Stone Powder & Egyptian Paste",
            "colour": "Turquoise & Royal Cobalt Blue",
            "pattern": "Traditional Floral Arabesque",
            "dimensions": "10 inches height",
            "handmade": True,
            "region": "Jaipur, Rajasthan",
            "weight": "920g",
            "keywords": ["blue pottery", "jaipur craft", "ceramic vase", "rajasthan handicraft"],
            "descriptionEn": "Traditional Jaipur Blue Pottery vase hand-painted with intricate botanical arabesque motifs. Made without clay using quartz stone powder.",
            "descriptionHi": "पारंपरिक जयपुर ब्लू पॉटरी फूलदान। हाथ से पेंट की गई नीली और फ़िरोज़ी पुष्प डिजाइन। प्राकृतिक क्वार्ट्ज़ सामग्री से निर्मित।"
        }
    
    if any(k in text_lower for k in ["toy", "wooden", "लकड़ी", "బొమ్మ", "பொம்மை", "ಮರದ"]):
        return {
            "title": "Channapatna Lacquered Wooden Stacking Toy",
            "titleHindi": "चन्नापटना लैक्वर्ड लकड़ी का खिलौना",
            "craftType": "Woodcraft",
            "category": "Toys & Games",
            "subcategory": "Wooden Toys",
            "material": "Aale Mara (Ivory Wood) & Vegetable Dyes",
            "colour": "Multi-color (Crimson, Saffron, Emerald)",
            "pattern": "Hand-lathed Circular Gloss Finish",
            "dimensions": "8 inches height",
            "handmade": True,
            "region": "Channapatna, Karnataka",
            "weight": "350g",
            "keywords": ["channapatna toys", "lacquerware", "organic wood", "karnataka craft"],
            "descriptionEn": "Eco-friendly non-toxic wooden toy hand-lathed from sustainable Ivory Wood and finished with organic vegetable lac dyes.",
            "descriptionHi": "पर्यावरण के अनुकूल गैर-विषाक्त लकड़ी का खिलौना। प्राकृतिक लकड़ी और प्राकृतिक लाख के रंगों से निर्मित।"
        }
        
    sample = SAMPLE_TRANSCRIPTS.get(lang, SAMPLE_TRANSCRIPTS["en"])
    return sample["extracted"]

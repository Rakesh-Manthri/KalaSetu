"""
Multilingual Product Information Extractor
Converts artisan speech transcripts into structured product metadata.
"""

import re

from matplotlib import text


MATERIALS = {
    "cotton": "Cotton",
    "పత్తి": "Cotton",
    "सूती": "Cotton",
    "silk": "Silk",
    "పట్టు": "Silk",
    "रेशम": "Silk",
    "wool": "Wool",
    "ऊन": "Wool",
    "wood": "Wood",
    "लकड़ी": "Wood",
    "చెక్క": "Wood",
    "bamboo": "Bamboo",
    "बांस": "Bamboo",
    "మట్టి": "Clay",
    "clay": "Clay",
    "pottery": "Clay",
    "brass": "Brass",
    "पीतल": "Brass",
}

CRAFTS = {
    "ikat": "Ikat",
    "ఇక్కత్": "Ikat",
    "इकत": "Ikat",
    "pottery": "Pottery",
    "मिट्टी": "Pottery",
    "కుండ": "Pottery",
    "handloom": "Handloom",
    "handwoven": "Handloom",
    "చేనేత": "Handloom",
    "हाथ से बुना": "Handloom",
    "embroidery": "Embroidery",
    "कढ़ाई": "Embroidery",
    "wooden": "Woodcraft",
    "लकड़ी": "Woodcraft",
    "చెక్క": "Woodcraft",
    "toy": "Woodcraft",
}

COLOURS = {
    "red": "Red",
    "ఎరుపు": "Red",
    "लाल": "Red",
    "blue": "Blue",
    "నీలం": "Blue",
    "नीला": "Blue",
    "green": "Green",
    "ఆకుపచ్చ": "Green",
    "हरा": "Green",
    "yellow": "Yellow",
    "పసుపు": "Yellow",
    "पीला": "Yellow",
    "black": "Black",
    "నలుపు": "Black",
    "काला": "Black",
    "white": "White",
    "తెలుపు": "White",
    "सफेद": "White",
}

REGIONS = {
    "pochampally": "Pochampally, Telangana",
    "పోచంపల్లి": "Pochampally, Telangana",
    "पोचमपल्ली": "Pochampally, Telangana",
    "jaipur": "Jaipur, Rajasthan",
    "जयपुर": "Jaipur, Rajasthan",
    "channapatna": "Channapatna, Karnataka",
    "चन्नापटना": "Channapatna, Karnataka",
    "kanchipuram": "Kanchipuram, Tamil Nadu",
    "कांचीपुरम": "Kanchipuram, Tamil Nadu",
    "varanasi": "Varanasi, Uttar Pradesh",
    "वाराणसी": "Varanasi, Uttar Pradesh",
}


def find_value(text, dictionary):
    text_lower = text.lower()

    for keyword, value in dictionary.items():
        if keyword.lower() in text_lower:
            return value

    return None


def extract_number(text, patterns):
    for pattern in patterns:
        match = re.search(pattern, text.lower())

        if match:
            try:
                return float(match.group(1))
            except:
                pass

    return None


def extract_product_details(text: str, lang: str = "en") -> dict:
    """
    Extract product information from an artisan's transcript.
    """

    if not text or not text.strip():
        return {
            "title": "Handcrafted Artisan Product",
            "titleHindi": "हस्तनिर्मित कारीगर उत्पाद",
            "craftType": None,
            "category": "Handicrafts",
            "subcategory": None,
            "material": None,
            "colour": None,
            "pattern": None,
            "dimensions": None,
            "handmade": True,
            "region": None,
            "weight": None,
            "labourHours": None,
            "keywords": [],
            "descriptionEn": "",
            "descriptionHi": "",
            "rawText": text
        }

    craft = find_value(text, CRAFTS)
    material = find_value(text, MATERIALS)
    colours_found = []

    for keyword, value in COLOURS.items():
        if keyword.lower() in text.lower() and value not in colours_found:
            colours_found.append(value)

    colour = " & ".join(colours_found) if colours_found else None
    region = find_value(text, REGIONS)

    # Detect length
    length = extract_number(
        text,
        [
            r"(\d+(?:\.\d+)?)\s*(?:meters|metres|मीटर|మీటర్లు|மீட்டர்)",
            r"(\d+(?:\.\d+)?)\s*m\b"
        ]
    )

    # Detect production time
    days = extract_number(
        text,
        [
            r"(\d+(?:\.\d+)?)\s*(?:days|day|రోజులు|दिन)",
            r"(\d+(?:\.\d+)?)\s*(?:days?)"
        ]
    )

    # Detect weight
    weight = extract_number(
        text,
        [
            r"(\d+(?:\.\d+)?)\s*(?:g|grams|గ్రాములు|ग्राम)"
        ]
    )

    dimensions = None

    if length:
        dimensions = f"{length} meters"

    # Generate title
    title_parts = []

    if craft:
        title_parts.append(craft)

    if material:
        title_parts.append(material)

    if "saree" in text.lower() or "చీర" in text or "साड़ी" in text:
        title_parts.append("Saree")
        subcategory = "Sarees"
    elif "toy" in text.lower() or "బొమ్మ" in text or "खिलौना" in text:
        title_parts.append("Toy")
        subcategory = "Wooden Toys"
    elif "vase" in text.lower() or "కుండ" in text or "फूलदान" in text:
        title_parts.append("Vase")
        subcategory = "Vases & Home Decor"
    else:
        subcategory = "Handcrafted Products"

    title = "Handcrafted " + " ".join(title_parts)

    if title == "Handcrafted ":
        title = "Handcrafted Artisan Product"

    # Keywords
    keywords = []

    for value in [craft, material, colour, region]:
        if value:
            keywords.append(value.lower())

    keywords.append("handmade")
    keywords.append("artisan craft")

    # English description
    description_parts = []

    if craft:
        description_parts.append(f"This is a traditional {craft.lower()} craft product.")
    else:
        description_parts.append(
            "This is a handcrafted product made by an artisan."
        )

    if material:
        description_parts.append(
            f"It is made using {material.lower()}."
        )

    if colour:
        description_parts.append(
            f"The product features {colour.lower()} colours."
        )

    if region:
        description_parts.append(
            f"It represents the traditional craft heritage of {region}."
        )

    if days:
        description_parts.append(
            f"The artisan takes approximately {int(days)} days to create it."
        )

    description_en = " ".join(description_parts)

    # Hindi description
    description_hi = (
        "यह एक पारंपरिक हस्तनिर्मित कारीगर उत्पाद है। "
    )

    if material:
        description_hi += f"इसे {material} से बनाया गया है। "

    if colour:
        description_hi += f"इसमें {colour} रंगों का उपयोग किया गया है। "

    if region:
        description_hi += f"यह {region} की पारंपरिक कला को दर्शाता है। "

    if days:
        description_hi += f"इसे बनाने में लगभग {int(days)} दिन लगते हैं।"

    return {
        "title": title,
        "titleHindi": "हस्तनिर्मित कारीगर उत्पाद",
        "craftType": craft,
        "category": "Handicrafts",
        "subcategory": subcategory,
        "material": material,
        "colour": colour,
        "pattern": None,
        "dimensions": dimensions,
        "handmade": True,
        "region": region,
        "weight": f"{weight}g" if weight else None,
        "labourHours": days * 8 if days else None,
        "keywords": keywords,
        "descriptionEn": description_en,
        "descriptionHi": description_hi,
        "rawText": text
    }

if __name__ == "__main__":

    text = """
    This is a Pochampally Ikat cotton saree.
    It is red and blue and handwoven.
    The saree is 6.3 meters long.
    It takes 3 days to make.
    """

    result = extract_product_details(text, "en")

    print(result)
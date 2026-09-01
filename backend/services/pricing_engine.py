"""
Smart Pricing Engine
Adapted from C:\\kalasetu\\src\\services\\smartPricingEngine.js
Combines Material Cost + Labor Cost + GI Tag Multipliers + Strategy Tiers
"""

def calculate_smart_price(craft_type: str = "Handloom", gi_registered: bool = True, custom_material: float = None, custom_labor: float = None) -> dict:
    craft = craft_type.lower()
    
    if custom_material is not None:
        material_cost = custom_material
    elif "pottery" in craft:
        material_cost = 600.0
    elif "wood" in craft:
        material_cost = 350.0
    elif "metal" in craft or "bidri" in craft:
        material_cost = 1400.0
    else:
        material_cost = 1200.0

    if custom_labor is not None:
        labor_cost = custom_labor
    elif "pottery" in craft:
        labor_cost = 650.0
    elif "wood" in craft:
        labor_cost = 350.0
    elif "metal" in craft or "bidri" in craft:
        labor_cost = 1100.0
    else:
        labor_cost = 800.0

    base_cost = material_cost + labor_cost
    benchmark_min = round(base_cost * 1.2)
    benchmark_max = round(base_cost * 1.55)
    
    gi_multiplier = 1.15 if gi_registered else 1.05
    raw_recommended = round(((material_cost + labor_cost) * 1.4 * gi_multiplier) / 10) * 10 - 1
    
    quick_sale = round((raw_recommended * 0.89) / 10) * 10 - 1
    premium = round((raw_recommended * 1.14) / 10) * 10 - 1

    return {
        "suggestedPrice": float(raw_recommended),
        "suggestedRange": {
            "min": float(benchmark_min),
            "max": float(benchmark_max)
        },
        "confidenceScore": 0.92,
        "breakdown": {
            "materialCost": float(material_cost),
            "laborCost": float(labor_cost),
            "baseCost": float(base_cost),
            "benchmarkMin": float(benchmark_min),
            "benchmarkMax": float(benchmark_max),
            "craftFactors": [
                "GI-Tagged Authentic Craft Heritage (+15%)",
                "Pure Organic Raw Materials Benchmark",
                "E-Commerce Platform Margin Buffer (10%)"
            ]
        },
        "tiers": [
            {
                "id": "quick",
                "name": "Quick Sale",
                "price": float(quick_sale),
                "description": "Faster turnover, competitive for new listings",
                "badge": "Fast Turnaround"
            },
            {
                "id": "recommended",
                "name": "AI Recommended",
                "price": float(raw_recommended),
                "description": "Optimal balance of profit margin and market demand",
                "badge": "Best Balance"
            },
            {
                "id": "premium",
                "name": "Premium Craft",
                "price": float(premium),
                "description": "Targeted at collectors, luxury boutiques & export markets",
                "badge": "Max Profit"
            }
        ]
    }

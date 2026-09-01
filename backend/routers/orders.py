from fastapi import APIRouter

router = APIRouter(prefix="/api/v1/orders", tags=["ONDC & Network Orders"])

@router.get("")
async def get_orders():
    return [
        {
            "id": "ORD-9843",
            "orderNumber": "#ORD-9843",
            "sourceNetwork": "Via ONDC · Taj Heritage Hotels",
            "productTitle": "Bell Metal Dhokra Peacock Oil Lamp",
            "quantity": 5,
            "price": 16000.0,
            "status": "newOrder",
            "imageUrl": "https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600&auto=format&fit=crop&q=80"
        },
        {
            "id": "ORD-9844",
            "orderNumber": "#ORD-9844",
            "sourceNetwork": "Via ONDC · Sanya Malhotra",
            "productTitle": "Handcrafted Jaipur Blue Pottery Floral Vase",
            "quantity": 1,
            "price": 1850.0,
            "status": "newOrder",
            "imageUrl": "https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600&auto=format&fit=crop&q=80"
        },
        {
            "id": "ORD-9842",
            "orderNumber": "#ORD-9842",
            "sourceNetwork": "Via Craftsvilla Boutique",
            "productTitle": "Handwoven Pochampally Ikat Pure Cotton Saree",
            "quantity": 3,
            "price": 8397.0,
            "status": "inTransit",
            "imageUrl": "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80"
        },
        {
            "id": "ORD-9841",
            "orderNumber": "#ORD-9841",
            "sourceNetwork": "Via Hastkala Export Traders",
            "productTitle": "Channapatna Wooden Toys Stacking Set",
            "quantity": 20,
            "price": 19000.0,
            "status": "completed",
            "imageUrl": "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=600&auto=format&fit=crop&q=80"
        }
    ]

@router.post("/{order_id}/accept")
async def accept_order(order_id: str):
    return {"success": True, "orderId": order_id, "status": "inTransit"}

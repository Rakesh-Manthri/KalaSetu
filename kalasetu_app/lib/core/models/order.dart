enum OrderStatus { newOrder, inTransit, completed }

class OrderItem {
  final String id;
  final String orderNumber;
  final String sourceNetwork; // 'Via ONDC Network' or 'Via Paytm Mall'
  final String productTitle;
  final int quantity;
  final double price;
  final OrderStatus status;
  final String imageUrl;
  final DateTime createdAt;

  const OrderItem({
    required this.id,
    required this.orderNumber,
    required this.sourceNetwork,
    required this.productTitle,
    required this.quantity,
    required this.price,
    required this.status,
    required this.imageUrl,
    required this.createdAt,
  });
}

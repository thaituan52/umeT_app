class OrderItem {
  final int id;
  //final int orderId;
  final int productId;
  final int quantity;
  final double pricePerUnit;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    //required this.orderId,
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String,dynamic> json) {
    return OrderItem(
      id: json['id'],
      //orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      pricePerUnit: json['price_per_unit'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

}
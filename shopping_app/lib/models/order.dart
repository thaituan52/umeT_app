import 'order_item.dart';

class Order {
  final int id;
  final int userId;
  final int status;
  final double totalAmount;
  final String? shippingAdress;
  final String? billingMethod;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id, 
    required this.userId, 
    required this.status, 
    required this.totalAmount, 
    required this.shippingAdress, 
    required this.billingMethod, 
    required this.contactPhone, 
    required this.createdAt, 
    required this.updatedAt, 
    required this.items});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      userId: json['userId'] as int,
      status: json['status'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      shippingAdress: json['shippingAdress'] as String?,
      billingMethod: json['billingMethod'] as String?,
      contactPhone: json['contactPhone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  
}
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

// In your Order class
//respond dont have userId and status
factory Order.fromJson(Map<String, dynamic> json, {int userId = 1, int status = 1}) {
  final totalAmount = (json['total_amount'] as num?)?.toDouble() ?? 0.0;
  final createdAt = json['created_at'] != null 
    ? DateTime.parse(json['created_at'] as String) 
    : DateTime.now(); // Fallback to now if not available

  final updatedAt = json['updated_at'] != null 
    ? DateTime.parse(json['updated_at'] as String) 
    : DateTime.now(); // Fallback to now if not available
  final id = json['id'] as int;
  final items = (json['items'] as List<dynamic>?) // Use a nullable list
      ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
      .toList() ?? []; // Provide an empty list if 'items' is null

  return Order(
    id: id,
    // Add dummy values for userId and status for now, as they are not in the JSON.
    // You should get these from your API or another source.
    userId: userId, 
    status: status, //userCart's status is always 1
    
    totalAmount: totalAmount,
    shippingAdress: json['shippingAdress'] as String?,
    billingMethod: json['billingMethod'] as String?,
    contactPhone: json['contactPhone'] as String?,
    createdAt: createdAt,
    updatedAt: updatedAt,
    items: items,
  );
}

  
}
import 'order_item.dart';

class Order {
  final int id;
  final String userUid;
  final int status;
  final double totalAmount;
  final int? shippingAddressId;
  final String? billingMethod;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id, 
    required this.userUid, 
    required this.status, 
    required this.totalAmount, 
    required this.shippingAddressId, 
    required this.billingMethod, 
    required this.contactPhone, 
    required this.createdAt, 
    required this.updatedAt, 
    required this.items});

// In your Order class
//respond dont have userId and status
factory Order.fromJson(Map<String, dynamic> json, userUid) {
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
  final status = json['status'] as int?; // Assuming status is an int,

  return Order(
    id: id,
    // Add dummy values for userId and status for now, as they are not in the JSON.
    // You should get these from your API or another source.
    userUid: userUid, 
    status: status ?? 1, 
    
    totalAmount: totalAmount,
    shippingAddressId: json['shipping_address'] as int?,
    billingMethod: json['billing_method'] as String?,
    contactPhone: json['contact_phone'] as String?,
    createdAt: createdAt,
    updatedAt: updatedAt,
    items: items,
  );
}
}
class OrderUpdate {
  // final int? status;
  final int? shippingAddressId;
  final String? billingMethod;
  final String? contactPhone;

  OrderUpdate({ //make the update do not contain status
    // this.status,
    this.shippingAddressId,
    this.billingMethod,
    this.contactPhone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    // if (status != null) {
    //   data['status'] = status;
    // }
    if (shippingAddressId != null) {
      data['shipping_address_id'] = shippingAddressId;
    }
    if (billingMethod != null) {
      data['billing_method'] = billingMethod;
    }
    if (contactPhone != null) {
      data['contact_phone'] = contactPhone;
    }
    return data;
  }
}

import 'package:flutter/material.dart';
import '../models/order_item.dart'; // Assuming you have an OrderItem model
import '../models/product.dart'; // Assuming you have a Product model

class OrderItemCard extends StatelessWidget {
  final OrderItem orderItem;
  final Product product; // Assuming you can fetch or pass the product associated with the order item

  const OrderItemCard({
    Key? key,
    required this.orderItem,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            // Assuming productIcon expects a CartItemDetails or similar.
            // You might need to adapt productIcon or create a simpler image display here.
            // For simplicity, let's just use the product image if available.
            child: product.imageURL != null && product.imageURL!.isNotEmpty
                ? Image.network(
                    product.imageURL!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 30),
                  )
                : const Icon(Icons.shopping_bag_outlined, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${orderItem.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  '\$${orderItem.pricePerUnit.toStringAsFixed(2)} / item',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${(orderItem.pricePerUnit * orderItem.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
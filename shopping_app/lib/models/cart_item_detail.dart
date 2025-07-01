// Combined model for displaying cart items
import 'order_item.dart';
import 'product.dart';

class CartItemDetails {
  final OrderItem orderItem;
  final Product product;

  CartItemDetails({required this.orderItem, required this.product});
}
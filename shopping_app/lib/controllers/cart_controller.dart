
import 'package:flutter/material.dart';
import 'package:shopping_app/service/product_service.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../service/cart_service.dart';


// Combined model for displaying cart items
class CartItemDetails {
  final OrderItem orderItem;
  final Product product;

  CartItemDetails({required this.orderItem, required this.product});
}


class CartController extends ChangeNotifier {
  final CartService _cartService = CartService();
  //final ProductService _productService = ProductService();

  Order? _cart;

  bool _isLoading = false;
  String? _error;
  String _userUid;
  List<CartItemDetails> _cartItemsWithDetails = [];

  CartController({required UserModel user}) : _userUid = user.uid; 
  //I am still get some trouble with the usermodel dont have the id so now just working on a specific user

  // Getters
  Order? get cart => _cart;
  List<CartItemDetails> get cartItemsWithDetails => _cartItemsWithDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cartItemCount => _cartItemsWithDetails.length;
  double get totalAmount => _cart?.totalAmount ?? 0.0;

  //Load user's cart
  Future<void> loadCart() async {
    _setLoading(true);
    _error = null;

    try {
      _cart = await _cartService.getUserCart(_userUid);
      final List<OrderItem> orderItems = _cart?.items ?? [];

      final List<Future<CartItemDetails?>> futures = orderItems.map((item) async {
        final Product product = await ProductService.getProductById(item.productId); // Product ID is int here
        return CartItemDetails(orderItem: item, product: product); // Product not found for this order item
      }).toList();

      final List<CartItemDetails?> results = await Future.wait(futures);
      _cartItemsWithDetails = results.whereType<CartItemDetails>().toList();
    } catch (e, stacktrace) {
      _error = 'Failed to load cart: $e';
      debugPrint('Error loading cart: $e\n$stacktrace');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addItemToCart(
    int productId, 
    {int quantity = 1
    }) async {
      try {
        final success = await _cartService.addItemToCart(_userUid, productId, quantity: quantity);
        if (success) {
          await loadCart();
          return true;
        }
        return false;
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        return false;
      }

    }

  // Remove item from cart
  Future<bool> removeItem(int itemId) async {
    try {
      final success = await _cartService.removeOrderItem(itemId);
      if (success) {
        // Remove item from local list immediately for better UX
        _cartItemsWithDetails.removeWhere((cartItem) => cartItem.orderItem.id == itemId);
        
        notifyListeners();
        
        // Reload cart to sync with server
        await loadCart();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  // Refresh cart data
  Future<void> refreshCart() async {
    await loadCart();
  }


  void _setLoading(bool loading) {
  _isLoading = loading;
  notifyListeners();
  }


  String? getImageUrl(CartItemDetails cartItemDetails) {
    final product = cartItemDetails.product;
    if (product.imageURL != null && product.imageURL!.isNotEmpty) {
      return product.imageURL;
    }
    return null;
  }

  
}
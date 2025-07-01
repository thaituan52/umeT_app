import 'package:flutter/material.dart';
import 'package:shopping_app/service/product_service.dart';
import '../models/cart_item_detail.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../service/cart_service.dart';

class CartController extends ChangeNotifier {
  final CartService _cartService;
  
  UserModel? user; // This will be set by the LoginCheck widget.

  Order? _cart;
  bool _isLoading = false;
  String? _error;
  
  List<CartItemDetails> _cartItemsWithDetails = [];

  CartController({
    required CartService cartService,
  }) : _cartService = cartService;


  // Getters
  Order? get cart => _cart;
  List<CartItemDetails> get cartItemsWithDetails => _cartItemsWithDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Returns the total quantity of all items in the cart
  int get totalCartQuantity {
    int total = 0;
    for (final item in _cartItemsWithDetails) {
      total += item.orderItem.quantity;
    }
    return total;
  } 

  double get totalAmount => _cart?.totalAmount ?? 0.0;


  // Load user's cart
  Future<void> loadCart() async {
    // <--- CHANGE: Add a check for the user. --->
    if (user == null) {
      debugPrint('loadCart called but user is null. Aborting.');
      return; // Abort if there's no user to load a cart for.
    }
    
    _setLoading(true);
    _error = null;

    try {
      // <--- CHANGE: Use the public 'user' property. --->
      _cart = await _cartService.getUserCart(user!.uid);
      final List<OrderItem> orderItems = _cart?.items ?? [];

      final List<Future<CartItemDetails?>> futures = orderItems.map((item) async {
        final Product product = await ProductService.getProductById(item.productId);
        return CartItemDetails(orderItem: item, product: product);
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
      // <--- CHANGE: Add a check for the user. --->
      if (user == null) {
        _error = 'Cannot add to cart: User is not authenticated.';
        notifyListeners();
        return false;
      }

      try {
        final success = await _cartService.addItemToCart(user!.uid, productId, quantity: quantity);
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
    // <--- CHANGE: Add a check for the user. --->
    if (user == null) {
      _error = 'Cannot remove from cart: User is not authenticated.';
      notifyListeners();
      return false;
    }

    try {
      final success = await _cartService.removeOrderItem(itemId);
      if (success) {
        _cartItemsWithDetails.removeWhere((cartItem) => cartItem.orderItem.id == itemId);
        notifyListeners();
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
}
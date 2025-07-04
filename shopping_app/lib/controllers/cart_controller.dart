import 'package:flutter/material.dart';
import 'package:shopping_app/models/shipping_address.dart';
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
    // Add a check for the user.
    if (user == null) {
      debugPrint('loadCart called but user is null. Aborting.');
      return; // Abort if there's no user to load a cart for.
    }
    
    _setLoading(true);
    _error = null;

    try {
      //Use the public 'user' property.
      _cart = await _cartService.getUserCart(user!.uid);
      final List<OrderItem> orderItems = _cart?.items ?? [];

      final List<Future<CartItemDetails?>> futures = orderItems.map((item) async {
        final Product product = await ProductService.getProductById(item.productId); //temporal
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
      //Add a check for the user.
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


    Future<void> placeOrder(int orderId, ShippingAddress selectedAddress) async {

    try {

      // 1. Update billing method and shipping address using the first API call
      final String billingMethod = "Cash on Delivery"; // Example billing method

      final OrderUpdate orderDetailsUpdate = OrderUpdate(
        billingMethod: billingMethod,
        shippingAddressId: selectedAddress.id, // Use the selected address ID
        // Do NOT set status here if you want to use the second API call for it
      ); 
      // Call the first updateOrder function to update details
      await _cartService.updateOrder(
        orderId, // The order ID from your widget
        orderDetailsUpdate,
        user!.uid,
      );
      
      // 2. Update the order status to 2 (shipping) using the second API call
      // You can hardcode 2 here as per your requirement "update its status to 2 (shipping)"
      await _cartService.updateOrderStatus(
        user!.uid,
        orderId,
        2, // Status for 'shipping'
      );

      loadCart(); // Refresh the cart after placing the order
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      rethrow;
    }
  }
}
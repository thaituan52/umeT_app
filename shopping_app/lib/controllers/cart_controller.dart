// lib/controllers/cart_controller.dart

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

  // New property for user's past orders
  List<Order>? _userOrders;
  bool _ordersLoading = false;
  String? _ordersError;


  CartController({
    required CartService cartService,
  }) : _cartService = cartService;


  // Getters
  Order? get cart => _cart;
  List<CartItemDetails> get cartItemsWithDetails => _cartItemsWithDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Order>? get userOrders => _userOrders;
  bool get ordersLoading => _ordersLoading;
  String? get ordersError => _ordersError;


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
    if (user == null) {
      debugPrint('loadCart called but user is null. Aborting.');
      _error = 'User not authenticated.'; // Set an error for the cart
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      _cart = await _cartService.getUserCart(user!.uid);
      final List<OrderItem> orderItems = _cart?.items ?? [];

      final List<Future<CartItemDetails?>> futures = orderItems.map((item) async {
        //TODO: Handle potential null product from service
        final Product product = await ProductService.getProductById(item.productId);
        // if (product != null) {
        //   return CartItemDetails(orderItem: item, product: product);
        // }
        // return null; // Return null if product not found
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
    if (user == null) {
      _error = 'Cannot remove from cart: User is not authenticated.';
      notifyListeners();
      return false;
    }

    try {
      final success = await _cartService.removeOrderItem(itemId);
      if (success) {
        // Directly remove from _cartItemsWithDetails for immediate UI update
        _cartItemsWithDetails.removeWhere((cartItem) => cartItem.orderItem.id == itemId);
        // Recalculate total if necessary or reload cart
        await loadCart(); // This will refresh all cart details
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

  // New method to fetch user's past orders
  Future<void> fetchUserOrders() async {
    if (user == null) {
      debugPrint('fetchUserOrders called but user is null. Aborting.');
      _ordersError = 'User not authenticated.'; // Set error for orders
      notifyListeners();
      _userOrders = []; // Ensure it's an empty list
      return;
    }

    _setOrdersLoading(true);
    _ordersError = null; // Clear previous errors

    try {
      _userOrders = await _cartService.getUserOrders(user!.uid);
    } catch (e, stacktrace) {
      _ordersError = 'Failed to load orders: $e';
      debugPrint('Error loading orders: $e\n$stacktrace');
      _userOrders = []; // Ensure it's an empty list on error
    } finally {
      _setOrdersLoading(false);
    }
  }

  void _setOrdersLoading(bool loading) {
    _ordersLoading = loading;
    notifyListeners();
  }

  // Renamed to clarify its purpose (from 'placeOrder' in the previous answer)
  // This handles updating an existing order (like a cart becoming an actual order).
  Future<void> finalizeOrder(int orderId, ShippingAddress selectedAddress) async {
    if (user == null) {
      throw Exception('User is not authenticated to finalize order.');
    }
    if (cart == null) {
        throw Exception('No active cart to finalize.');
    }

    try {
      final String billingMethod = "Cash on Delivery"; // This could be dynamic from UI

      // 1. Update billing method and shipping address
      final OrderUpdate orderDetailsUpdate = OrderUpdate(
        billingMethod: billingMethod,
        shippingAddressId: selectedAddress.id,
        // Status is updated in a separate call for clarity/control
      );
      await _cartService.updateOrder(
        orderId,
        orderDetailsUpdate,
        user!.uid,
      );

      // 2. Update the order status to 2 (shipping/processing)
      await _cartService.updateOrderStatus(
        user!.uid,
        orderId,
        2, // Status for 'shipping' or 'processing'
      );

      // After finalizing, the current cart should ideally be cleared or reset,
      // and a new one might be created implicitly by the backend/service.
      // We should also refresh the user's past orders list.
      _cart = null; // Clear the current cart
      _cartItemsWithDetails = []; // Clear detailed items
      await fetchUserOrders(); // Refresh the list of past orders
      notifyListeners(); // Notify UI that cart and orders have changed
    } catch (e) {
      // Re-throw the exception for the UI to handle messages
      rethrow;
    }
  }

  // You might want a dedicated method for fetching a single order if needed,
  // but `getUserOrders` fetches all for the OrdersScreen.
}
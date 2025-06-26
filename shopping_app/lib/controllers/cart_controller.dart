
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/user.dart';
import '../service/cart_service.dart';

class CartController extends ChangeNotifier {
  final CartService _cartService = CartService();

  Order? _cart;
  List<OrderItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  String _userUid;

  CartController({required UserModel user}) : _userUid = user.uid; 
  //I am still get some trouble with the usermodel dont have the id so now just working on a specific user

  // Getters
  Order? get cart => _cart;
  List<OrderItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cartItemCount => _cartItems.length;
  double get totalAmount => _cart?.totalAmount ?? 0.0;

  //Load user's cart
  Future<void> loadCart() async {
    _setLoading(true);
    _error = null;

    try {
      _cart = await _cartService.getUserCart(_userUid);
      _cartItems = _cart?.items ?? [];
    } catch (e) {
      _error = e.toString();
      _cart = null;
      _cartItems = [];
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
        _cartItems.removeWhere((item) => item.id == itemId);
        
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
  
}
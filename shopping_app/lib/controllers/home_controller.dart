import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/models/order_item.dart';

import '../models/category.dart';
import '../models/user.dart';
import '../service/cart_service.dart';
import '../service/categories_service.dart';

class HomeController {
  final CartService _cartService = CartService();


  String _searchQuery = "search";
  int _cartItemCount = 0;
  List<Category> _categories = [];
  int _selectedCategoryIndex = 0;
  bool _isLoadingCategories = true;
  final UserModel? user;
  final Function onStateUpdate;
  bool _isLoadingCart = false;

  String get searchQuery => _searchQuery;
  int get cartItemCount => _cartItemCount;
  List<Category> get categories => _categories;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get  isLoadingCart => _isLoadingCart;

  HomeController({required this.user, required this.onStateUpdate});

  
  Future<void> loadCategories() async {
    if(_categories.isNotEmpty) {
      return;
    }
    _isLoadingCategories = true;
    onStateUpdate();
    final categories = await CategoriesService.getCategories();
    _categories = [Category(id: 0, name: "All", isActive: true)] + categories;
    _isLoadingCategories = false;
    onStateUpdate();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.isEmpty ? "search" : query;
    onStateUpdate();
  }

  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    onStateUpdate();
  }

  Future<void> loadCart() async {
    if (user == null) {
      _cartItemCount = 0;
      onStateUpdate();
      return;
    }

    _isLoadingCart = true;
    onStateUpdate();

    try {
      // Use the instance method instead of static access
      final cart = await _cartService.getUserCart(user!.uid);
      final List<OrderItem> orderItems = cart?.items ?? [];
      _cartItemCount = orderItems.length;
    } catch (e) {
      print('Error loading cart: $e');
      _cartItemCount = 0;
      // Handle error appropriately - maybe show a snackbar or error state
    } finally {
      _isLoadingCart = false;
      onStateUpdate();
    }
  }

  Future<void> refreshCart() async {
    await loadCart();
  }

    // Method to add item to cart and refresh count
  Future<bool> addToCart(int productId, {int quantity = 1}) async {
    if (user == null) return false;

    try {
      final success = await _cartService.addItemToCart(
        user!.uid, 
        productId, 
        quantity: quantity
      );
      
      if (success) {
        // Refresh cart count after successful addition
        await loadCart();
      }
      
      return success;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Method to remove item from cart and refresh count
  Future<bool> removeFromCart(int itemId) async {
    try {
      final success = await _cartService.removeOrderItem(itemId);
      
      if (success) {
        // Refresh cart count after successful removal
        await loadCart();
      }
      
      return success;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }


  void handleHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity! < 0 &&
        _selectedCategoryIndex < (_categories.length) - 1) {
      _selectedCategoryIndex++;
      onStateUpdate();
    } else if (details.primaryVelocity! > 0 && _selectedCategoryIndex > 0) {
      _selectedCategoryIndex--;
      onStateUpdate();
    }

  }

  Future<bool> signOutFromGoogle() async { 
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }  

  
}
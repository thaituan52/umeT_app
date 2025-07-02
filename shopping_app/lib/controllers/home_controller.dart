import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shopping_app/models/order_item.dart';

import '../models/category.dart';
import '../models/user.dart';
import '../service/cart_service.dart';
import '../service/categories_service.dart';
import '../service/product_service.dart';

class HomeController extends ChangeNotifier{
  UserModel? user; 
  final CategoriesService _categoriesService;
  // final CartService _cartService;
  // final ProductService _productService;


  String _searchQuery = "search";
  List<Category> _categories = [];
  int _selectedCategoryIndex = 0;
  bool _isLoadingCategories = false;
  bool _isLoadingCart = false;

  String get searchQuery => _searchQuery;
  List<Category> get categories => _categories;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get  isLoadingCart => _isLoadingCart;

  HomeController({
    required CategoriesService categoriesService,
    // required ProductService productService,
    }) : //  _productService = productService, 
         _categoriesService = categoriesService

         {
          loadCategories();
         }

  
  Future<void> loadCategories() async {
    if(_categories.isNotEmpty) {
      return;
    }
    setLoadingCategories(true);
    final categories = await _categoriesService.getCategories();
    _categories = [Category(id: 0, name: "All", isActive: true)] + categories;
    setLoadingCategories(false);
  }

  void setLoadingCategories(bool loading) {
    _isLoadingCategories = loading;
    notifyListeners();
  }

    Future<void> resetState() async {
    _selectedCategoryIndex = 0; // Reset the category index to the first one
    //user = null; // Also clear the user model
    notifyListeners();
    debugPrint('HomeController state has been reset.');
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.isEmpty ? "search" : query;
    notifyListeners();
  }

  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }


  void handleHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity! < 0 &&
        _selectedCategoryIndex < (_categories.length) - 1) {
      _selectedCategoryIndex++;
      notifyListeners();
    } else if (details.primaryVelocity! > 0 && _selectedCategoryIndex > 0) {
      _selectedCategoryIndex--;
      notifyListeners();
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


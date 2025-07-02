import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/service/product_service.dart';
// import 'package:shopping_app/models/order_item.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../service/categories_service.dart';

class HomeController extends ChangeNotifier{

  final CategoriesService _categoriesService;
  final ProductService _productService;

  UserModel? user; 
  String _searchQuery = "search";
  List<Category> _categories = [];
  int _selectedCategoryIndex = 0; 

  bool _isLoadingCategories = false;
  bool _isLoadingCart = false;

  List<Product> _products = [];
  bool _isLoadingProduct = false;
  String? _productError;
  String? get productError => _productError;
  

  

  String get searchQuery => _searchQuery;
  List<Category> get categories => _categories;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get  isLoadingCart => _isLoadingCart;
  List<Product> get products => _products;
  bool get isLoadingProduct => _isLoadingProduct;

  HomeController({
    required CategoriesService categoriesService,
    required ProductService productService,
    }) : _productService = productService, 
         _categoriesService = categoriesService

         {
          loadCategories();
          loadProducts();
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

  
  Future<void> loadProducts() async {
    setLoadingProduct(true);
    try {
      final int? categoryId = selectedCategoryIndex == 0
          ? null
          : selectedCategoryIndex; // Adjust if your category IDs are 0-indexed or 1-indexed

      final String currentQuery = searchQuery == "search" ? '' : searchQuery;

      _products = await _productService.getProducts(
        categoryId: categoryId,
        query: currentQuery,
      );
      _productError = null; // Clear any previous error
    } catch (e) {
      _productError = 'Failed to load products: ${e.toString()}';
      _products = []; // Clear products on error
    } finally {
      setLoadingProduct(false);
    }
  }

  void setLoadingProduct(bool loading) {
    _isLoadingProduct = loading;
    notifyListeners();
  }

    Future<void> resetState() async {
    _selectedCategoryIndex = 0; 
    _searchQuery = "search"; 
    notifyListeners();
    // await loadProducts();
    debugPrint('HomeController state has been reset.');
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.isEmpty ? "search" : query;
    notifyListeners();
    loadProducts();
  }

  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
    loadProducts();
  }


  void handleHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity! < 0 &&
        _selectedCategoryIndex < (_categories.length) - 1) {
      _selectedCategoryIndex++;
      notifyListeners();
      loadProducts();
    } else if (details.primaryVelocity! > 0 && _selectedCategoryIndex > 0) {
      _selectedCategoryIndex--;
      notifyListeners();
      loadProducts();
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


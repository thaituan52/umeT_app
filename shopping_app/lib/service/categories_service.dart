// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/category.dart';
import '../utils/constants.dart';


//need postAPI to check the api need

class CategoriesService {

  // Handle Google Sign-In with backend save
  Future<List<Category>> getCategories({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/categories/?skip=$skip&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if(response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((category) => Category.fromJson(category)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.body}');
      }
    }
    catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<Category> getCategoryByID(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/categories/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if(response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Category.fromJson(data);
      } else {
        throw Exception('Failed to load category: ${response.body}');
      }
    }
    catch (e) {
      print('Error fetching category: $e');
      rethrow;
    }
  }
    //havent used
    Future<Category> createCategory({
      required String name,
      String? description,
      bool isActive = true,
    }) async {
    try {
      final payload = {
        'name': name,
        'description' : description,
        'is_active': isActive,
      };

      final response = await http.post(
        Uri.parse('$apiBaseUrl/categories/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if(response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = json.decode(response.body);
        return Category.fromJson(data);
      } else {
        throw Exception('Failed to create category: ${response.body}');
      }
    }
    catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

}
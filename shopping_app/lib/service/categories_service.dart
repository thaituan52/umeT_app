// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/category.dart';


//need postAPI to check the api need

class CategoriesService {
  static const String _apiBaseUrl = 'http://10.0.2.2:8000'; 

  // Handle Google Sign-In with backend save
  static Future<List<Category>> getCategories({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/categories/?skip=$skip&limit=$limit'),
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

  static Future<Category> getCategoryByID(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/categories/$categoryId'),
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
    static Future<Category> createCategory({
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
        Uri.parse('$_apiBaseUrl/categories/'),
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
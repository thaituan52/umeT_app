// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/product.dart';
import '../utils/constants.dart';

//need postAPI to check the api need

class ProductService {
  static const String _apiBaseUrl = '$apiBaseUrl/products';


  static Future<List<Product>> getProducts({
    int skip = 0,
    int limit = 100,
    int? categoryId,
    String? query,
  }) async {
    try {
      String url = '$_apiBaseUrl/?skip=$skip&limit=$limit';
      url += categoryId == null ? '' : '&category_id=$categoryId';

      if(query != null && query.isNotEmpty) {
        url += '&q=${Uri.encodeComponent(query)}';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if(response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception('Failed to load products: ${response.body}');
      }
    }
    catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  static Future<Product> getProductById(
    int productId,
    ) async {
    try {

      final response = await http.get(
        Uri.parse('$_apiBaseUrl/$productId'),
        headers: {'Content-Type': 'application/json'},
      );


      if(response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load products: ${response.body}');
      }
    }
    catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

}
// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order.dart';


class CartService {
  static const String _apiBaseUrl = 'http://10.0.2.2:8000';

  //retrieve the current cart
  Future<Order?> getUserCart(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/users/$userId/cart/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        return Order.fromJson(data, userId: userId, status:  1);
      } else if (response.statusCode == 404) {
          return null; //cart not found
      } else { //internal sever problem
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  //get all order to display
  Future<List<Order>?> getUserOrders(
    int userId,
    {
      int skip = 0, 
      int limit = 100,
    }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_apiBaseUrl/users/$userId/orders/?skip=$skip&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((order) => Order.fromJson(order)).toList();
      } else { //internal sever problem
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network errore: $e');
    }
  }

  Future<bool> addItemToCart(
    int userId, 
    int productId,
    {int quantity = 1
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/$userId/cart/items/?product_id=$productId&quantity=$quantity'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> removeOrderItem(int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/order-items/$itemId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }  
}
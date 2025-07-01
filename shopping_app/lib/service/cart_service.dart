// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order.dart';
import '../utils/constants.dart';

class CartService {

  //retrieve the current cart
  Future<Order?> getUserCart(String userUid) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users/$userUid/cart/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Order.fromJson(data, userUid, status:  1);
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
    String userUid,
    {
      int skip = 0, 
      int limit = 100,
    }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$apiBaseUrl/users/$userUid/orders/?skip=$skip&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((order) => Order.fromJson(order, userUid)).toList();
      } else { //internal sever problem
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network errore: $e');
    }
  }

  Future<bool> addItemToCart(
    String userUid, 
    int productId,
    {int quantity = 1
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/users/$userUid/cart/items/?product_id=$productId&quantity=$quantity'),
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
        Uri.parse('$apiBaseUrl/order-items/$itemId'),
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
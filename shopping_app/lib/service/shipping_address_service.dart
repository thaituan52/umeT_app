import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/shipping_address.dart'; 
import '../utils/constants.dart';


class ShippingAddressService {
  // Use the same base URL as your CartService

  // Private helper for headers (can be expanded for auth if needed)
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer YOUR_AUTH_TOKEN_HERE', // Uncomment and set if needed
    };
  }

  /// Creates a new shipping address for a user.
  /// Returns the created ShippingAddress on success, null on 400, or throws for other errors.
  Future<ShippingAddress?> createAddress({ // Changed return type to ShippingAddress
    required String userUid,
    required ShippingAddressCreate addressData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/user/$userUid/addresses/'),
        headers: _getHeaders(),
        body: jsonEncode(addressData.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ShippingAddress.fromJson(data); // Using ShippingAddress.fromJson
      } else if (response.statusCode == 400) {
        // Bad request, e.g., validation error from backend
        print('Bad request to create address: ${response.body}');
        return null;
      } else {
        // Other server errors
        throw Exception('Failed to create address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during createAddress: $e');
    }
  }

  /// Gets all shipping addresses for a user.
  /// Returns a list of ShippingAddress, or null for other errors.
  Future<List<ShippingAddress>?> getAddresses({ // Changed return type to List<ShippingAddress>
    required String userUid,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/user/$userUid/addresses/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ShippingAddress.fromJson(item)).toList(); // Using ShippingAddress.fromJson
      } else if (response.statusCode == 404) {
        // User not found or no addresses, can return empty list or null as per preference
        return []; // Returning an empty list is often more convenient than null for a list
      }
      else {
        throw Exception('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during getAddresses: $e');
    }
  }

  Future<ShippingAddress?> getAddressesByID({ // Changed return type to List<ShippingAddress>
    required String addressId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/addresses/$addressId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ShippingAddress.fromJson(data); // Using ShippingAddress.fromJson
      } else if (response.statusCode == 404) {
        // User not found or no addresses, can return empty list or null as per preference
        return null; // Returning an empty list is often more convenient than null for a list
      }
      else {
        throw Exception('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during getAddresses: $e');
    }
  }

  /// Updates an existing shipping address.
  /// Returns the updated ShippingAddress on success, null on 404/400, or throws for other errors.
  Future<ShippingAddress?> updateAddress({ // Changed return type to ShippingAddress
    required String userUid,
    required int addressId,
    required ShippingAddressUpdate addressUpdateData,
  }) async {
    try {
      // Assuming your backend uses PUT for full replacement, not PATCH for partial update
      // If it's PATCH, change http.put to http.patch
      final response = await http.put(
        Uri.parse('$apiBaseUrl/user/$userUid/addresses/$addressId'),
        headers: _getHeaders(),
        body: jsonEncode(addressUpdateData.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ShippingAddress.fromJson(data); // Using ShippingAddress.fromJson
      } else if (response.statusCode == 404) {
        print('Address not found during update: ${response.body}');
        return null;
      } else if (response.statusCode == 400) {
        print('Bad request to update address: ${response.body}');
        return null; // e.g., validation error from backend
      } else {
        throw Exception('Failed to update address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during updateAddress: $e');
    }
  }

  /// Deletes a shipping address.
  /// Returns true on success, false if not found or due to a 400 business rule, or throws for other errors.
  Future<bool> deleteAddress({
    required String userUid,
    required int addressId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/user/$userUid/addresses/$addressId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return true; // Deletion successful
      } else if (response.statusCode == 404) {
        print('Address not found for deletion: ${response.body}');
        return false;
      } else if (response.statusCode == 400) {
        // Business rule violation (e.g., trying to delete the last default address)
        print('Deletion denied by business rule: ${response.body}');
        return false;
      } else {
        throw Exception('Failed to delete address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during deleteAddress: $e');
    }
  }
}

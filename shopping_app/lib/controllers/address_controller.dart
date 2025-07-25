import 'package:flutter/material.dart';
import 'package:shopping_app/controllers/home_controller.dart';

import '../models/shipping_address.dart';
import '../service/shipping_address_service.dart';

class AddressController extends ChangeNotifier {
  final ShippingAddressService _shippingAddressService;
  final HomeController _homeController;

  List<ShippingAddress> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  //getter methods
  List<ShippingAddress> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AddressController({
    required ShippingAddressService shippingAddressService,
    required HomeController homeController,
  }) : _shippingAddressService = shippingAddressService,
       _homeController = homeController 
       {
        loadAddresses();
       }

  void resetAddress() {
    _addresses = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _setErrorMessage(null);
  }

  Future<void> loadAddresses() async {
    final userUid = _homeController.user?.uid;
    if (userUid == null) {
      _setErrorMessage("User not logged in. Cannot load addresses");
      _addresses = [];
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final fetchAddresses = await _shippingAddressService.getAddresses(userUid: userUid);
      _addresses = fetchAddresses ?? []; //if null, assign empty
    } catch  (e) {
      _setErrorMessage('Failed to load addresses"$e');
      _addresses = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addAddress(ShippingAddressCreate addressData) async {
    final userUid = _homeController.user?.uid;
    if (userUid == null) {
      _setErrorMessage("User not logged in. Cannot load addresses");
      return false;
    }

    try {
      final newAddress = await _shippingAddressService.createAddress(
        userUid: userUid,
        addressData: addressData);
      if (newAddress != null) {
        loadAddresses();
        return true;
      } else {
        _setErrorMessage('Failed to add address');
        return false;
      }
    } catch  (e) {
      _setErrorMessage('Failed to load addresses"$e');
      return false;
    }
  }


  Future<bool> updateAddress(int addressId, ShippingAddressUpdate updateData) async {
    final userUid = _homeController.user?.uid;
    if (userUid == null) {
      _setErrorMessage('User not logged in. Cannot update address.');
      return false;
    }


    try {
      final updatedAddress = await _shippingAddressService.updateAddress(
        userUid: userUid,
        addressId: addressId,
        addressUpdateData: updateData,
      );
      if (updatedAddress != null) {
        loadAddresses();
        return true;
      } else {
        _setErrorMessage('Failed to update address: Address not found or invalid data.');
        return false;
      }
    } catch (e) {
      _setErrorMessage('Error updating address: $e');
      return false;
    }
  }

  Future<bool> deleteAddress(int addressId) async {
    final userUid = _homeController.user?.uid;
    if (userUid == null) {
      _setErrorMessage('User not logged in. Cannot delete address.');
      return false;
    }
    try {
      final success = await _shippingAddressService.deleteAddress(
        userUid: userUid,
        addressId: addressId,
      );
      if (success) {
        loadAddresses();
        return true;
      } else {
        _setErrorMessage('Failed to delete address: Not found or forbidden.');
        return false;
      }
    } catch (e) {
      _setErrorMessage('Error deleting address: $e');
      return false;
    }
  }

   Future<void> refreshAddresses() async {
    await loadAddresses();
  }




}
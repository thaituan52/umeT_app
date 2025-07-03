import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import '../models/shipping_address.dart';
import 'address_form.dart';

class AddressSelectionSheet extends StatelessWidget {
  final AddressController controller;
  final ShippingAddress? currentAddress;

  const AddressSelectionSheet({
    super.key,
    required this.controller,
    required this.currentAddress,
  });

  // Helper to edit an address (re-uses your existing AddressFormDialog)
  Future<void> _editAddress(BuildContext context, ShippingAddress address) async {
    final result = await showDialog<ShippingAddressUpdate>(
      context: context,
      builder: (ctx) => AddressFormDialog(initialAddress: address),
    );

    if (result != null && !controller.isLoading) {
      await controller.updateAddress(address.id, result);
      // Close the sheet after editing is complete
      if (context.mounted) Navigator.pop(context, controller.addresses.firstWhere((addr) => addr.id == address.id));
    }
  }
  
  // Helper to add a new address
  Future<void> _addNewAddress(BuildContext context) async {
      final result = await showDialog<ShippingAddressCreate>(
          context: context,
          builder: (ctx) => const AddressFormDialog(),
      );

      if (result != null && !controller.isLoading) {
          final success = await controller.addAddress(result);
          if (success && context.mounted) {
              // Pop with the newly added address
              Navigator.pop(context, controller.addresses.last);
          }
      }
  }


  @override
  Widget build(BuildContext context) {
    // Consumer listens to changes in the AddressController
    return Consumer<AddressController>(
      builder: (context, addressController, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // List of addresses
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: addressController.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressController.addresses[index];
                    final isSelected = currentAddress?.id == address.id;

                    return Card(
                      color: isSelected ? Colors.orange : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: isSelected ? Colors.orange : Colors.grey.shade300,
                              width: 1.5,
                          ),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () {
                          // Pop the sheet and return the selected address
                          Navigator.of(context).pop(address);
                        },
                        title: Text(address.address, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: address.isDefault ? const Text("Default Address") : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () => _editAddress(context, address),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Button to add a new address
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text("Add a New Address"),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange)
                  ),
                  onPressed: () => _addNewAddress(context),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
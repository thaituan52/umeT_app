// lib/views/checkout_screen.dart (Updated)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/models/cart_item_detail.dart';
import 'package:shopping_app/widgets/product_icon.dart'; // Import productIcon
import '../controllers/address_controller.dart';
import '../controllers/cart_controller.dart';
import '../widgets/address_form.dart';
import '../models/shipping_address.dart';
import '../models/order.dart';

class CheckoutScreen extends StatefulWidget {
  final Order order;

  const CheckoutScreen({super.key, required this.order});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ShippingAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    final addressController = Provider.of<AddressController>(context, listen: false);
    
    if (addressController.addresses.isNotEmpty) {
      _selectedAddress = addressController.addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => addressController.addresses.first,
      );
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a shipping address.")),
        );
        return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Processing payment...")),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context, true); // return success flag
  }

  void _showAddressSelection() async {
    final addressController = Provider.of<AddressController>(context, listen: false);

    final newSelectedAddress = await showModalBottomSheet<ShippingAddress>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return AddressSelectionSheet(
          controller: addressController,
          currentAddress: _selectedAddress,
        );
      },
    );

    if (newSelectedAddress != null) {
      setState(() {
        _selectedAddress = newSelectedAddress;
      });
    }
  }

  // NEW: Helper widget to display a single cart item row (read-only)
  Widget _buildCartItemRow(CartItemDetails itemDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: productIcon(itemDetails), // Using your existing productIcon
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemDetails.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${itemDetails.orderItem.quantity}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${(itemDetails.orderItem.pricePerUnit * itemDetails.orderItem.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout (${cartController.totalCartQuantity})'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      // MODIFIED: Wrapped body in SingleChildScrollView
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Deliver To:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _showAddressSelection,
                    child: const Text("Change", style: TextStyle(color: Colors.orange)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedAddress != null)
                Text(
                  "${cartController.user!.displayName}\n${_selectedAddress!.address}",
                  style: const TextStyle(fontSize: 15, height: 1.4),
                )
              else
                const Text("No address selected.", style: TextStyle(color: Colors.grey)),
              
              const Divider(height: 32),

              // NEW: Items Summary Section
              const Text("Your Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...cartController.cartItemsWithDetails.map((item) => _buildCartItemRow(item)),
              const Divider(height: 32),
              // END NEW SECTION

              const Text("Order Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("\$${widget.order.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, color: Colors.orange, fontWeight: FontWeight.bold)),
              
              // Spacing before the button
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.money),
                  label: const Text("Pay with Cash"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _handlePayment,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// AddressSelectionSheet remains the same...

// You can create this as a new widget in a separate file or at the bottom of checkout_screen.dart

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
                      color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white,
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
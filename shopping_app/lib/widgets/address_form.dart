// lib/widgets/address_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:shopping_app/models/shipping_address.dart';

class AddressFormDialog extends StatefulWidget {
  final ShippingAddress? initialAddress; // Null if adding, non-null if editing

  const AddressFormDialog({super.key, this.initialAddress});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress?.address ?? '');
    _isDefault = widget.initialAddress?.isDefault ?? false;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.initialAddress == null) {
        // Creating a new address
        final newAddress = ShippingAddressCreate(
          address: _addressController.text,
          isDefault: _isDefault,
        );
        Navigator.of(context).pop(newAddress);
      } else {
        // Updating an existing address
        final updatedAddress = ShippingAddressUpdate(
          address: _addressController.text,
          isDefault: _isDefault,
        );
        Navigator.of(context).pop(updatedAddress);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialAddress == null ? 'Add New Address' : 'Edit Address'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Street Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: const Text('Set as Default Address'),
                value: _isDefault,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isDefault = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
          },
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
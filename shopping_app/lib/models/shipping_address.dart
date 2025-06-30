class ShippingAddress {
  final int id;
  final String userUid;
  final String address; 
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ShippingAddress({
    required this.id,
    required this.userUid,
    required this.address, 
    required this.isDefault,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a ShippingAddress from a JSON map
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] as int,
      userUid: json['user_uid'] as String,
      address: json['address'] as String, 
      isDefault: json['is_default'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_uid': userUid,
      'address': address, 
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ShippingAddressCreate { 
  final String address; 
  final bool isDefault;

  ShippingAddressCreate({ 
    required this.address, 
    required this.isDefault,
  });

  // Method to convert this object to a JSON map for the API request body
  Map<String, dynamic> toJson() {
    return {
      'address': address, 
      'is_default': isDefault,
    };
  }
}

class ShippingAddressUpdate {
  final String? address;
  final bool? isDefault;

  ShippingAddressUpdate({
    this.address,
    this.isDefault,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (address != null) {
      data['address'] = address;
    }
    if (isDefault != null) {
      data['is_default'] = isDefault;
    }
    return data;
  }
}

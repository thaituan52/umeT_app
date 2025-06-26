import './category.dart';

class Product { //model for products so that I can put to db later like user
  final int id;
  final String name;
  final String? description;
  final String? imageURL;
  final double price;
  final int soldCount; //soldNum
  final double rating;
  final int reviewsCount; //considerable
  final String deliveryInfo;
  final String sellerInfo;
  //new fields
  final int stockQuantity; 
  final bool isActive; 
  final List<Category> categories; 
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageURL,
    required this.price,
    required this.soldCount,
    required this.rating,
    required this.reviewsCount,
    required this.deliveryInfo,
    required this.sellerInfo,
    this.stockQuantity = 0,
    this.isActive = true,
    this.categories = const [],
    this.createdAt,
    this.updatedAt,
  });


  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageURL: json['image_url'],
      price: (json['price'] as num).toDouble(),
      soldCount: json['sold_count'] ?? 0,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['review_count'] ?? 0,
      deliveryInfo: json['delivery_info'],
      sellerInfo: json['seller_info'],
      stockQuantity: json['stock_quantity'] ?? 0,
      isActive: json['is_active'] ?? true,
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((category) => Category.fromJson(category))
              .toList()
          : [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageURL,
      'price': price,
      'sold_count': soldCount,
      'rating': rating,
      'review_count': reviewsCount,
      'delivery_info': deliveryInfo,
      'seller_info': sellerInfo,
      'stock_quantity': stockQuantity,
      'is_active': isActive,
      'categories': categories.map((category) => category.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  //Helper method
  String get categoryNames {
    return categories.map((category) => category.name).join(', ');
  }

  bool belongsToCategory(int categoryId) {
    return categories.any((category) => category.id == categoryId);
  }
}

class ProductCreate {
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final int soldCount;
  final double rating;
  final int reviewCount;
  final String? deliveryInfo;
  final String? sellerInfo;
  final int stockQuantity;
  final bool isActive;
  final List<int> categoryIds;

  ProductCreate({
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    this.soldCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.deliveryInfo,
    this.sellerInfo,
    this.stockQuantity = 0,
    this.isActive = true,
    this.categoryIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'sold_count': soldCount,
      'rating': rating,
      'review_count': reviewCount,
      'delivery_info': deliveryInfo,
      'seller_info': sellerInfo,
      'stock_quantity': stockQuantity,
      'is_active': isActive,
    };
  }
}
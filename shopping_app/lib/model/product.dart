import 'package:flutter/material.dart';
import 'package:shopping_app/model/category.dart';

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






  class ProductCard extends StatelessWidget {
    final Product product;
    final VoidCallback onTap;
    final VoidCallback onAddToCart;

    const ProductCard({
      super.key,
      required this.product,
      required this.onTap,
      required this.onAddToCart,
    });

    String? _getImageUrl() {
    if (product.imageURL != null && product.imageURL!.isNotEmpty) {
      return product.imageURL;
    }
    return null;
  }

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140, 
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: _getImageUrl() != null
                      ? Image.network(
                          _getImageUrl()!,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                        ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.deliveryInfo,
                      style: TextStyle(fontSize: 10, color: Colors.green[600]),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < product.rating.floor()
                                ? Icons.star
                                : (index < product.rating ? Icons.star_half : Icons.star_border),
                            color: Colors.orange[400],
                            size: 12,
                          );
                        }),
                        SizedBox(width: 4),
                        Text(
                          "${product.rating}",
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      product.sellerInfo,
                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[600],
                                ),
                              ),
                              Text(
                                "${product.soldCount} sold",
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,

                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    }
  }

  class ProductDetailsModel extends StatelessWidget {
    final Product product;
    final VoidCallback onAddToCart;
    final VoidCallback onBuyNow;

    const ProductDetailsModel({
      super.key,
      required this.product,
      required this.onAddToCart,
      required this.onBuyNow,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 24, color: Colors.orange[600]),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < product.rating.floor()
                        ? Icons.star
                        : (index < product.rating ? Icons.star_half : Icons.star_border),
                    color: Colors.orange[400],
                    size: 16,
                  );
                }),
                SizedBox(width: 8),
                Text("${product.rating}"),
              ],
            ),
            SizedBox(height: 10),
            Text(product.deliveryInfo),
            SizedBox(height: 10),
            Text(product.sellerInfo),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("Add to Cart", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBuyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 158, 129, 163),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("Buy Now", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  
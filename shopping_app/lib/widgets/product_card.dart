import 'package:flutter/material.dart';

import '../models/product.dart';

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
              color: Colors.grey.withValues(),
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
                            // child: Text(
                            //     'Add now'
                            //   ),
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
  
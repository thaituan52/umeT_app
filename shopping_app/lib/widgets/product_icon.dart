  import 'package:flutter/material.dart';

import '../models/cart_item_detail.dart';

Widget productIcon(CartItemDetails cartItemDetails) {
    final imageUrl = getImageUrl(cartItemDetails);
    return Center(
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
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
              child: const Icon(
                Icons.image,
                size: 80,
                color: Colors.grey,
              ),
            ),
    );
  }

  String? getImageUrl(CartItemDetails cartItemDetails) {
    final product = cartItemDetails.product;
    if (product.imageURL != null && product.imageURL!.isNotEmpty) {
      return product.imageURL;
    }
    return null;
  }
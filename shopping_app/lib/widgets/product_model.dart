import 'package:flutter/material.dart';

import '../models/product.dart';

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
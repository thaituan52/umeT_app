import 'package:flutter/material.dart';
import './product_card.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../service/product_service.dart';
import '../views/product_detail_screen.dart';

  class ProductGridWidget extends StatelessWidget {
    final int? categoryId;
    final String searchQuery;
    final UserModel? user;
    final int cartItemCount;
    final Function(Product)? onAddToCartExternal;
    final Function(Product)? onBuyNowExternal;

    const ProductGridWidget({
      super.key,
      required this.categoryId,
      required this.searchQuery,
      required this.user,
      required this.cartItemCount,
      this.onAddToCartExternal,
      this.onBuyNowExternal,
    });

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<List<Product>>(
    future: ProductService.getProducts(
      categoryId: categoryId == 0 ? null : categoryId,
      query: searchQuery == "search" ? '' : searchQuery,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text('No products found.'));
      } else {
        List<Product> products = snapshot.data!;
        return GridView.builder(

            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),

            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: product,
                      user: user!,
                      cartItemCount: cartItemCount, // Pass the cart count here
                      onAddToCart: () {
                        onAddToCartExternal?.call(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Added to cart")),
                        );
                      },
                      onBuyNow: () {
                        onBuyNowExternal?.call(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Proceeding to checkout...")),
                        );
                      },
                    ),
                  ),
                ),
                onAddToCart: () {
                  onAddToCartExternal?.call(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Added to cart!"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          );
      }
    },
  );
    }
  }
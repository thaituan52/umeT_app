import 'package:flutter/material.dart';
import 'package:shopping_app/controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
import './product_card.dart';
import '../models/product.dart';
import '../views/product_detail_screen.dart';

class ProductGridWidget extends StatelessWidget {

  final HomeController homeController;
  final CartController cartController;

  const ProductGridWidget({
    super.key,
    required this.homeController, // Home and Cart controllers are now passed in directly
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    if (homeController.isLoadingProduct) {
      return const Center(child: CircularProgressIndicator());
    } else if (homeController.productError != null) {
      // Use controller's error state
      return Center(child: Text('Error: ${homeController.productError}'));
    } else if (homeController.products.isEmpty) {
      // Use controller's product list
      return const Center(child: Text('No products found.'));
    } else {
      List<Product> products = homeController.products; // Direct access to products

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
                ),
              ),
            ),
            onAddToCart: () async {
              // Made async to await the cart operation
              await cartController.addItemToCart(product.id, quantity: 1);
              if (context.mounted) {
                // Check if the widget is still in the tree before showing SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Added to cart!"),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          );
        },
      );
    }
  }
}
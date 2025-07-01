import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';
import '../models/cart_item_detail.dart';
import '../models/user.dart';
import '../widgets/product_icon.dart';
import 'check_out_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    final HomeController homeController = Provider.of<HomeController>(context, listen: false);

    return Consumer<CartController>(
      builder: (context, controller, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.error!),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: controller.clearError,
                ),
              ),
            );
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: canPop
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : null,
            title: const Text(
              'Shopping Cart',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                onPressed: controller.isLoading ? null : controller.refreshCart,
              ),
            ],
          ),
          body: _buildBody(context, controller, canPop, homeController.user), // Pass context here
        );
      },
    );
  }

  // Pass context as the first parameter
  Widget _buildBody(BuildContext context, CartController controller, bool canPop, UserModel? user) {
    if (controller.isLoading) {
      return _buildLoadingState();
    }
    if (controller.error != null) {
      return _buildErrorState(context, controller); // Pass context here
    }
    if (controller.totalCartQuantity == 0) {
      return _buildEmptyCart(context, canPop); // Pass context here
    }

    return _buildCartItems(context, controller, user); // Pass context here
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Loading your cart...',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 117, 117, 117),
            ),
          ),
        ],
      ),
    );
  }

  // Pass context as the first parameter
  Widget _buildErrorState(BuildContext context, CartController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              controller.clearError();
              controller.refreshCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Pass context as the first parameter
  Widget _buildEmptyCart(BuildContext context, bool canPop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add some items to get started!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          if (canPop) ...[
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Pass context as the first parameter
  Widget _buildCartItems(BuildContext context, CartController controller, UserModel? user) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshCart,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.cartItemsWithDetails.length,
              itemBuilder: (context, index) {
                final cartItemDetails = controller.cartItemsWithDetails[index];
                return _buildCartItemCard(context, cartItemDetails, controller); // Pass context here
              },
            ),
          ),
        ),
        _buildCheckoutSection(context, controller, user), // Pass context here
      ],
    );
  }

  // Pass context as the first parameter
  Widget _buildCartItemCard(BuildContext context, CartItemDetails cartItemDetails, CartController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: productIcon(cartItemDetails),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItemDetails.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cartItemDetails.product.description}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${cartItemDetails.orderItem.pricePerUnit.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: controller.isLoading ? null : () async {
                    await controller.addItemToCart(cartItemDetails.product.id);
                  },
                  icon: Icon(
                    Icons.add,
                    color: controller.isLoading ? Colors.grey : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: controller.isLoading ? null : () async {
                    await controller.removeItem(cartItemDetails.orderItem.id);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: controller.isLoading ? Colors.grey : Colors.red,
                  ),
                ),
                if (cartItemDetails.orderItem.quantity > 0)
                  IconButton(
                    onPressed: controller.isLoading ? null : () async {
                      await controller.addItemToCart(cartItemDetails.product.id, quantity: -1);
                    },
                    icon: Icon(
                      Icons.remove,
                      color: controller.isLoading ? Colors.grey : Colors.grey,
                    ),
                  ),
                Text('Qty: ${cartItemDetails.orderItem.quantity}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Pass context as the first parameter
  Widget _buildCheckoutSection(BuildContext context, CartController controller, UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${controller.totalCartQuantity} items):',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${controller.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading || controller.totalAmount == 0.0 ?
                  null :
                  () async {
                final success = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      user: user!,
                      order: controller.cart!,
                    ),
                  ),
                );
                if (success == true) {
                  controller.refreshCart();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment completed!')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
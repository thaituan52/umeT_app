import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../models/user.dart';
import 'check_out_screen.dart';

class CartScreen extends StatefulWidget {
  final UserModel user;

  const CartScreen({super.key, required this.user});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartController _cartController;

  @override
  void initState() {
    super.initState();
    _cartController = CartController(user: widget.user);
    _cartController.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    return ChangeNotifierProvider<CartController>(
      create: (_) => _cartController,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: canPop ? IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ) : null,
          title: Text(
            'Shopping Cart',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            Consumer<CartController>(
              builder: (context, controller, child) {
                return IconButton(
                  icon: Icon(Icons.refresh, color: Colors.black),
                  onPressed: controller.isLoading ? null : () {
                    controller.refreshCart();
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<CartController> (
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return _buildLoadingState();
            }
            if (controller.error != null) {
              print(controller.error);
              return _buildErrorState(controller);
            }

            if (controller.totalCartQuantity == 0) {
              return _buildEmptyCart(canPop);
            }

            return _buildCartItems(controller);
          }
        )
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16,),
          Text(
            'Loading your cart...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildErrorState(CartController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80, 
            color: Colors.red[400],
          ),
          SizedBox(height: 20),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(controller.error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              controller.clearError();
              controller.refreshCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEmptyCart(bool canPop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add some items to get started!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
            if (canPop) ...[
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              ),
              child: Text(
              'Start Shopping',
              style: TextStyle(fontSize: 16),
              ),
            ),
            ],
        ],
      ),
    );
  }

Widget _buildCartItems(CartController controller) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshCart,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.cartItemsWithDetails.length,
              itemBuilder: (context, index) {
                final cartItemDetails = controller.cartItemsWithDetails[index];
                return _buildCartItemCard(cartItemDetails, controller);
              },
            ),
          ),
        ),
        _buildCheckoutSection(controller),
      ],
    );
  }

  Widget _buildCartItemCard(CartItemDetails cartItemDetails, CartController controller) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              ),
              child: controller.productIcon(cartItemDetails),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItemDetails.product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${cartItemDetails.product.description}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${cartItemDetails.orderItem.pricePerUnit.toStringAsFixed(2)}',
                    style: TextStyle(
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
                    final success = await controller.addItemToCart(cartItemDetails.product.id);
                    if (!success && controller.error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add item: ${controller.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.add, 
                    color: controller.isLoading ? Colors.red : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: controller.isLoading ? null : () async {
                    final success = await controller.removeItem(cartItemDetails.orderItem.id);
                    if (!success && controller.error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to remove item: ${controller.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.delete_outline, 
                    color: controller.isLoading ? Colors.grey : Colors.red,
                  ),
                ),
                if(cartItemDetails.orderItem.quantity > 0)
                IconButton(
                  onPressed: controller.isLoading ? null : () async {
                    final success = await controller.addItemToCart(cartItemDetails.product.id, quantity: -1);
                    if (!success && controller.error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add item: ${controller.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.remove, 
                    color: controller.isLoading ? Colors.red : Colors.grey,
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

  Widget _buildCheckoutSection(CartController controller) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(2),
            blurRadius: 8,
            offset: Offset(0, -2),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${controller.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton( //procedding to payment page
              onPressed: controller.isLoading || controller.totalAmount == 0.0 ? 
              null : 
              () async {
                final success = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      user: widget.user,
                      order: controller.cart!,
                    ),
                  ),
                );
                if (success == true && mounted) {
                  _cartController.refreshCart(); // clear cart or refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment completed!')),
                );
              }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
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
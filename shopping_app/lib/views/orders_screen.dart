// lib/views/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/service/product_service.dart';
import '../models/order.dart';
import '../controllers/cart_controller.dart';
import '../widgets/order_item_card.dart';
import '../models/product.dart';
import 'check_out_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, List<int>> _statusFilters = {
    'All orders': [],
    'Processing': [2],
    'Delivered': [3],
    'Refunded/Cancelled': [0],
  };

  String _getOrderStatusString(int status) {
    switch (status) {
      case 0: return 'Refunded/Cancelled';
      case 1: return 'Pending';
      case 2: return 'Processing (Shipping)';
      case 3: return 'Delivered';
      default: return 'Unknown Status';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartController = Provider.of<CartController>(context, listen: false);

      if (cartController.user != null) {
        cartController.fetchUserOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your orders.')),
        );
      }
    });

    _tabController.addListener(_handleTabSelection);
  }
  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      final cartController = Provider.of<CartController>(context, listen: false);
      if (cartController.user != null) {
        cartController.fetchUserOrders();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
          tabs: _statusFilters.keys.map((tabName) => Tab(text: tabName)).toList(),
        ),
      ),
      body: Consumer<CartController>(
        builder: (context, cartController, child) {
          if (cartController.ordersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (cartController.ordersError != null) {
            return Center(child: Text('Error: ${cartController.ordersError}'));
          } else if (cartController.userOrders == null || cartController.userOrders!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            final allOrders = cartController.userOrders!;
            final String currentTabName = _statusFilters.keys.elementAt(_tabController.index);
            final List<int> currentFilterStatuses = _statusFilters[currentTabName]!;

            final filteredOrders = allOrders.where((order) {
              bool isCurrentCartStatus = order.status == 1;
              bool filterIncludesCurrentCart = currentFilterStatuses.contains(1);

              if (isCurrentCartStatus && !filterIncludesCurrentCart) {
                return false;
              }
              return currentFilterStatuses.isEmpty || currentFilterStatuses.contains(order.status);
            }).toList();

            if (filteredOrders.isEmpty) {
              return Center(child: Text('No orders in "$currentTabName" status.'));
            }

            final Map<String, List<Order>> groupedOrders = {};
            for (var order in filteredOrders) {
              final dateKey = DateFormat('MMM d,yyyy').format(order.updatedAt);
              groupedOrders.putIfAbsent(dateKey, () => []).add(order);
            }

            // Sort the date keys (groups) from latest to oldest
            final sortedDateKeys = groupedOrders.keys.toList()
              ..sort((a, b) => DateFormat('MMM d,yyyy').parse(b).compareTo(DateFormat('MMM d,yyyy').parse(a)));

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sortedDateKeys.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDateKeys[index];
                // Get orders for the current date group
                final ordersOnDate = groupedOrders[dateKey]!;

                // *** NEW: Sort orders within this date group by updatedAt, latest to oldest ***
                ordersOnDate.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(
                      dateKey,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('${ordersOnDate.length} order(s)'),
                    children: ordersOnDate.map((order) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  // This now formats the order's exact time
                                  DateFormat('MMM d,yyyy HH:mm').format(order.updatedAt),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _getOrderStatusString(order.status),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: order.status == 3 ? Colors.green : (order.status == 0 ? Colors.red : Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...order.items.map((item) {
                            final Product product = cartController.products.firstWhere(
                              (p) => p.id == item.productId,
                            );

                            // if (product == null) {
                            //   return const Padding(
                            //     padding: EdgeInsets.symmetric(vertical: 8.0),
                            //     child: Text('Product not found'),
                            //   );
                            // }

                            return OrderItemCard(orderItem: item, product: product);
                            }),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (order.status == 2)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () async { 
                                      await _handlePaymentwithStatus(order, 0); // Change status to Refunded/Cancelled
                                    }, 
                                    child: const Text('Return/Refund'),
                                  ),
                                  // TextButton(
                                  // onPressed: () { 
                                  //   /* TODO: Implement leave a review logic */ 
                                  // }, 
                                  // child: const Text('Leave a review'),
                                  // ),
                                  ElevatedButton(
                                    onPressed: () async { 
                                      await _handlePaymentwithStatus(order, 3);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Received'),
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final cartController = Provider.of<CartController>(context, listen: false);
                                      // 1. Call the new method to populate the cart with items from this order
                                      await cartController.populateCartFromOrder(order);

                                      // 2. Check for errors or success message from the controller
                                      if (cartController.error == null) {
                                        // 3. Navigate to the checkout screen with the populated cart
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => CheckoutScreen(
                                        //       order: order,
                                        //     ),
                                        //   ),
                                        // );
                                      } else {
                                        // Optional: Show a user-friendly error if populateCartFromOrder failed
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                          content: Text(cartController.error!),
                                          backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Reorder'),
                                  ),
                                ],
                              ),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

    Future<void> _handlePaymentwithStatus(Order order, int status) async {
    if (!mounted) return; // Check if the widget is still mounted before async operations

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Processing ...")),
    );

    try {
      final cartController = Provider.of<CartController>(context, listen: false);

      cartController.changingOrderStatus(
        order.id, // Use the order ID from the widget
        status
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order changed successfully!")),
      );
      Navigator.pop(context, true); // return success flag
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to change order: ${e.toString()}")),
      );
      print("Error during changing order status: $e"); // For debugging
    }
  }



}
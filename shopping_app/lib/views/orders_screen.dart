// lib/views/orders_screen.dart 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/service/product_service.dart';
import '../models/order.dart';
import '../controllers/cart_controller.dart'; 
import '../widgets/order_item_card.dart';
import '../models/product.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // No longer need CartService directly here, as CartController will manage it.
  // late final CartService _cartService; // REMOVE THIS LINE

  // No longer need _ordersFuture directly, as CartController will provide the list.
  // late Future<List<Order>?> _ordersFuture; // REMOVE THIS LINE
  // No longer need _userUid directly here, CartController manages it.
  // String? _userUid; // REMOVE THIS LINE

  // Define status filters (matching your backend statuses)
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
    // No longer initialize CartService here.
    // _cartService = CartService(); // REMOVE THIS LINE
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    // No longer initialize _ordersFuture here.
    // _ordersFuture = Future.value([]); // REMOVE THIS LINE

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the CartController instance
      final cartController = Provider.of<CartController>(context, listen: false);

      // Check if user is available in the controller
      if (cartController.user != null) {
        // Call the controller's method to fetch orders
        cartController.fetchUserOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your orders.')),
        );
        // Optionally, clear orders in controller if user logs out while on screen
        // though `fetchUserOrders` handles null user by setting _userOrders to empty.
      }
    });

    _tabController.addListener(_handleTabSelection);
  }

  // This method now triggers the CartController to re-fetch orders.
  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      // Get the CartController instance
      final cartController = Provider.of<CartController>(context, listen: false);
      // Trigger fetch only if a user is logged in
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
    // Use Consumer to listen for changes from CartController
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
      body: Consumer<CartController>( // Use Consumer to rebuild when CartController changes
        builder: (context, cartController, child) {
          if (cartController.ordersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (cartController.ordersError != null) {
            return Center(child: Text('Error: ${cartController.ordersError}'));
          } else if (cartController.userOrders == null || cartController.userOrders!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            final allOrders = cartController.userOrders!; // Get orders from the controller
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
              final dateKey = DateFormat('MMM d,yyyy').format(order.createdAt);
              groupedOrders.putIfAbsent(dateKey, () => []).add(order);
            }

            final sortedDateKeys = groupedOrders.keys.toList()
              ..sort((a, b) => DateFormat('MMM d,yyyy').parse(b).compareTo(DateFormat('MMM d,yyyy').parse(a)));

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sortedDateKeys.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDateKeys[index];
                final ordersOnDate = groupedOrders[dateKey]!;

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
                                  'Order ID: ${order.id}',
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
                              return FutureBuilder<Product?>(
                                future: ProductService.getProductById(item.productId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: LinearProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError || !snapshot.hasData) {
                                    return const Text('Product not found');
                                  } else {
                                    return OrderItemCard(orderItem: item, product: snapshot.data!);
                                  }
                                },
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(onPressed: () { /* TODO: Implement return/refund logic */ }, child: const Text('Return/Refund')),
                                TextButton(onPressed: () { /* TODO: Implement leave a review logic */ }, child: const Text('Leave a review')),
                                ElevatedButton(
                                  onPressed: () { /* TODO: Implement track logic */ },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Track'),
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
}
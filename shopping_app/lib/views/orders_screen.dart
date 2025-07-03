// lib/views/orders_screen.dart (Corrected)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';
import 'package:shopping_app/service/product_service.dart';
import '../models/order.dart';
import '../controllers/cart_controller.dart'; // To get userUid
import '../service/cart_service.dart';
import '../widgets/order_item_card.dart'; // The new widget

// You might need a Product model to pass to OrderItemCard if it's not nested in OrderItem
import '../models/product.dart'; // Assuming you have this

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final CartService _cartService;
  late Future<List<Order>?> _ordersFuture;
  String? _userUid;

  // Define status filters (matching your backend statuses)
  // Key: Tab name, Value: List of status integers for that tab
  final Map<String, List<int>> _statusFilters = {
    'All orders': [], // Empty list means no specific status filter
    'Processing': [2], // 2 for 'in progress / shipping'
    'Delivered': [3],  // 3 for 'done'
    'Refunded/Cancelled': [0], // 0 for 'cancelled / refund'
  };

  // Helper to map status integer to a display string (for the order header)
  String _getOrderStatusString(int status) {
    switch (status) {
      case 0: return 'Refunded/Cancelled';
      case 1: return 'Pending'; // Current cart is status 1, but usually not shown in past orders
      case 2: return 'Processing (Shipping)';
      case 3: return 'Delivered';
      default: return 'Unknown Status';
    }
  }

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _ordersFuture = Future.value([]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userUid = Provider.of<CartController>(context, listen: false).user?.uid;
      if (_userUid != null) {
        _fetchOrders();
      } else {
        // Handle case where userUid is not available (e.g., user not logged in)
        setState(() {
          _ordersFuture = Future.value([]); // Return empty list if no user
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your orders.')),
        );
      }
    });

    _tabController.addListener(_handleTabSelection);
  }

  void _fetchOrders() {
    if (_userUid == null) {
      setState(() {
        _ordersFuture = Future.value([]);
      });
      return;
    }
    setState(() {
      _ordersFuture = _cartService.getUserOrders(_userUid!);
    });
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      _fetchOrders();
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
          isScrollable: true, // If you have many tabs
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
          tabs: _statusFilters.keys.map((tabName) => Tab(text: tabName)).toList(),
        ),
      ),
      body: FutureBuilder<List<Order>?>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            final allOrders = snapshot.data!;
            // Corrected line: Access keys from _statusFilters map, not _tabController
            final String currentTabName = _statusFilters.keys.elementAt(_tabController.index);
            final List<int> currentFilterStatuses = _statusFilters[currentTabName]!;

            // Filter orders based on the selected tab
            final filteredOrders = allOrders.where((order) {
              // Exclude orders with status 1 (current cart) from past orders view, unless explicitly filtered
              // This line needs to be slightly more robust to prevent an error if a status '1' tab is added.
              // A safer check would be to see if _statusFilters.values actually contains status 1 in any list.
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

            // Group orders by creation date
            final Map<String, List<Order>> groupedOrders = {};
            for (var order in filteredOrders) {
              final dateKey = DateFormat('MMM d, yyyy').format(order.createdAt); // Use 'yyyy' for year
              groupedOrders.putIfAbsent(dateKey, () => []).add(order);
            }

            // Sort dates in descending order (most recent first)
            final sortedDateKeys = groupedOrders.keys.toList()
              ..sort((a, b) => DateFormat('MMM d, yyyy').parse(b).compareTo(DateFormat('MMM d, yyyy').parse(a)));

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
                            // Display a summary of items (e.g., first few items)
                            // or loop through all if the order detail isn't a separate screen
                            ...order.items.take(3).map((item) {
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
                            }),
                            if (order.items.length > 3)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text('...and ${order.items.length - 3} more items', style: TextStyle(color: Colors.grey[600])),
                              ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Action buttons like "Track", "Return/Refund", "Leave a review"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(onPressed: () { /* TODO: Implement return/refund logic */ }, child: const Text('Return/Refund')),
                                TextButton(onPressed: () { /* TODO: Implement leave a review logic */ }, child: const Text('Leave a review')),
                                ElevatedButton(
                                  onPressed: () { /* TODO: Implement track logic */ },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange, // Temu's orange accent
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Track'),
                                ),
                              ],
                            ),
                            const Divider(), // Separator between orders on the same day
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
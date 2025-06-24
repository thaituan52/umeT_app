import 'package:flutter/material.dart';

class TemuProfilePage extends StatefulWidget {
  const TemuProfilePage({Key? key}) : super(key: key);

  @override
  State<TemuProfilePage> createState() => _TemuProfilePageState();
}

class _TemuProfilePageState extends State<TemuProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Product> products = [
    Product(
      name: "Inflatable Portable Lazy...",
      price: 16.23,
      soldCount: "275 sold",
      image: "https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Lazy+Chair",
    ),
    Product(
      name: "Green Flame Candle",
      price: 4.44,
      soldCount: "7.9K+ sold",
      image: "https://via.placeholder.com/150x150/2E7D32/FFFFFF?text=Candle",
    ),
    Product(
      name: "LED Strip Light",
      price: 12.99,
      soldCount: "1.2K+ sold",
      image: "https://via.placeholder.com/150x150/9C27B0/FFFFFF?text=LED",
    ),
    Product(
      name: "Wireless Earbuds",
      price: 24.99,
      soldCount: "892 sold",
      image: "https://via.placeholder.com/150x150/2196F3/FFFFFF?text=Earbuds",
    ),
    Product(
      name: "Phone Stand Holder",
      price: 8.99,
      soldCount: "3.5K+ sold",
      image: "https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Stand",
    ),
    Product(
      name: "Bluetooth Speaker",
      price: 19.99,
      soldCount: "1.8K+ sold",
      image: "https://via.placeholder.com/150x150/E91E63/FFFFFF?text=Speaker",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with user info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // User profile section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.teal,
                        child: const Text(
                          'T',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Thai Tuan Do',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.headset_mic_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Promotion banners
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, 
                                color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'No import charges for all local warehouse items',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, 
                              color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              '\$5.00 Credit for delay',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, 
                              color: Colors.grey, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Notification banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_outlined),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Turn on Notifications for updates on your latest order status.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('OK'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu buttons
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuButton(
                    icon: Icons.message_outlined,
                    title: 'Messages',
                    badge: '29',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuButton(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your orders',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuButton(
                    icon: Icons.star_border,
                    title: 'Your reviews',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuButton(
                    icon: Icons.local_offer_outlined,
                    title: 'Coupons & offers',
                    trailing: '3 in total',
                    onTap: () {},
                  ),
                  _buildSpecialOffer(),
                  _buildDivider(),
                  _buildMenuButton(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Credit balance',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuButton(
                    icon: Icons.location_on_outlined,
                    title: 'Addresses',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuButton(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Gift Calendar',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab bar for browsing history and followed stores
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: 'Browsing history'),
                  Tab(text: 'Followed stores'),
                ],
              ),
            ),
            
            // Product grid
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductGrid(),
                    _buildProductGrid(), // Same grid for both tabs
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    String? badge,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (trailing != null)
            Text(
              trailing,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSpecialOffer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '\$1000',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'BUY TO UNLOCK GIFTS WORTH \$1,000',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Get'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                image: DecorationImage(
                  image: NetworkImage(product.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.soldCount,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 56,
    );
  }
}

class Product {
  final String name;
  final double price;
  final String soldCount;
  final String image;

  Product({
    required this.name,
    required this.price,
    required this.soldCount,
    required this.image,
  });
}
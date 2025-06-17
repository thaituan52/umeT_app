import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/login/login_init.dart';
import 'package:shopping_app/model/user.dart';

class Product { //model for products so that I can put to db later like user
  final int id;
  final String name;
  final String? image;
  final double price;
  final int sold; //soldNum
  final double rating;
  //final int reviews; //considerable
  final String deliveryInfo;
  final String sellerInfo;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    // required this.originalPrice,
    required this.sold,
    required this.rating,
    // required this.reviews,
    // this.isLocal = false,
    // this.isFathersDayDeal = false,
    // this.isClearanceDeal = false,
    // this.isAd = false,
    required this.deliveryInfo,
    required this.sellerInfo,
  });
}

class DatabaseService { //gonna bring it to another file later + make temp data to use rn
  static List<Product> _products = [
    Product(
      id: 1,
      name: "Waterproof Sofa Inflatable Bean Bag Chair",
      image: "🛋️",
      price: 17.25,
      //originalPrice: 25.00,
      sold: 854,
      rating: 4.8,
      //reviews: 141,
      //isLocal: true,
      deliveryInfo: "44.7% arrive in 3 business days",
      sellerInfo: "Seller established 1 year ago",
    ),
    Product(
      id: 2,
      name: "Butane Torch Lighter Double-Safe Welding",
      image: "🔥",
      price: 5.38,
      //originalPrice: 12.99,
      sold: 475,
      rating: 4.9,
      //reviews: 56,
      //isLocal: true,
      //isFathersDayDeal: true,
      //isAd: true,
      deliveryInfo: "Arrives in 2+ business days",
      sellerInfo: "High repeat customers store",
    ),
    Product(
      id: 3,
      name: "Versatile Shoe Rack Storage Organizer",
      image: "👟",
      price: 7.43,
      //originalPrice: 15.99,
      sold: 6559,
      rating: 4.3,
      //reviews: 6959,
      //isLocal: true,
      //isClearanceDeal: true,
      deliveryInfo: "Fast delivery",
      sellerInfo: "Low item return rate store",
    ),
    Product(
      id: 4,
      name: "Compact Speaker Magnetic Levitation",
      image: "🔊",
      price: 11.13,
      //originalPrice: 29.99,
      sold: 3,
      rating: 4.7,
      //reviews: 28,
      //isLocal: true,
      //isFathersDayDeal: true,
      deliveryInfo: "Fast delivery store",
      sellerInfo: "Reliable seller",
    ),
    Product(
      id: 5,
      name: "Wireless Bluetooth Earbuds Pro",
      image: "🎧",
      price: 23.99,
      //originalPrice: 59.99,
      sold: 1247,
      rating: 4.6,
      //reviews: 892,
      //isLocal: true,
      deliveryInfo: "2-3 business days",
      sellerInfo: "Top rated seller",
    ),
    Product(
      id: 6,
      name: "Smart Watch Fitness Tracker",
      image: "⌚",
      price: 34.50,
      //originalPrice: 89.99,
      sold: 567,
      rating: 4.4,
      //reviews: 234,
      //isLocal: true,
      deliveryInfo: "3-5 business days",
      sellerInfo: "Established store",
    ),
  ];

  static List<Product> getAllProducts() => _products;

  static void addProduct(Product product) {
    _products.add(product);
  }
}

class HomeScreen extends StatefulWidget {
  final UserModel? user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = "bean bag chair";
  int _cartItemCount = 29;
  List<String> _categories = ["All","Men", "Toy", "Women", "Home", "Sports", "Industrial", "Crafts", "Jewelry"];
  int _selectedCategoryIndex = 0; 

  // Google Sign-out method
  Future<bool> signOutFromGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  void _handleLogout(BuildContext context) async {
    try {
      bool success = await signOutFromGoogle();
      if (success) {
        // Navigate back to login screen
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()), //may need to adjust this on both platforms
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _selectedIndex == 0 ? _buildMainContent() : _buildOtherScreen(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryTabs(),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherScreen() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForIndex(_selectedIndex),
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              _getTitleForIndex(_selectedIndex),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              )
            )            
          ],
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 1: return Icons.category;
      case 2: return Icons.local_shipping;
      case 3: return Icons.shopping_cart;
      case 4: return Icons.person;
      default: return Icons.home; 
    }
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 1: return 'Categories';
      case 2: return '3-day Delivery';
      case 3: return 'Shopping Cart';
      case 4: return 'Profile';
      default: return 'Home';
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255,158,129,163),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showUserProfile(),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: widget.user?.photoURL != null 
                ? NetworkImage(widget.user!.photoURL!)
                : null,
              backgroundColor: Colors.grey[300],
              child: widget.user?.photoURL == null 
                ? Icon(Icons.person, size: 20, color: Colors.grey[600])
                : null,
            ),
          ),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.user?.displayName ?? 'User',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          ),

          //umeT logo???
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "umeT",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          SizedBox(width: 12),
          
          // Logout button
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255,158,129,163),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Local items",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "44.7% arrive in 3 business days",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: _searchQuery,
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.isEmpty? "bean bag chair" : value;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected? const Color.fromARGB(255, 158, 129, 163) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    List<Product> products = DatabaseService.getAllProducts();

    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        _showProductDetails(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140, 
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Text(
                      product.image ?? '',
                      style: TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.deliveryInfo,
                      style: TextStyle(fontSize: 10, color: Colors.green[600]),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < product.rating.floor()
                                ? Icons.star
                                : (index < product.rating ? Icons.star_half : Icons.star_border),
                            color: Colors.orange[400],
                            size: 12,
                          );
                        }),
                        SizedBox(width: 4),
                        Text(
                          "${product.rating}",
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      product.sellerInfo,
                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[600],
                                ),
                              ),
                              Text(
                                "${product.sold} sold",
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _cartItemCount++;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Added to cart!"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: Colors.orange[600],
      unselectedItemColor: Colors.grey[600],
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: "Categories",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping),
          label: "3-day delivery",
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.shopping_cart),
              if (_cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: "Cart",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "You",
        ),
      ],
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Product Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(product.image ?? '', style: TextStyle(fontSize: 80)),
                ),
              ),
              SizedBox(height: 16),
              Text(
                product.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "\$${product.price.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600],
                ),
              ),
              SizedBox(height: 8),
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
              SizedBox(height: 16),
              Text("${product.sold} sold"),
              SizedBox(height: 8),
              Text(product.deliveryInfo),
              SizedBox(height: 8),
              Text(product.sellerInfo),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _cartItemCount++;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Added to cart!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Add to Cart",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Proceeding to checkout...")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 158, 129, 163),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Buy Now",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: widget.user?.photoURL != null 
                  ? NetworkImage(widget.user!.photoURL!)
                  : null,
                backgroundColor: Colors.grey[300],
                child: widget.user?.photoURL == null 
                  ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                  : null,
              ),
              SizedBox(height: 16),
              Text(
                widget.user?.displayName ?? 'User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.user?.identifier ?? 'No email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleLogout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
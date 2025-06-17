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


  //   // Google Sign-out method
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
      body: _selectedIndex ==0? _buildMainContent() : _buildOtherScreen(),
      //bottomNavigationBar: _buildBottomNavBar(),
      );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          //_buildSearchBar(),
          //_buildCategoryTabs(),
          Expanded(
            child: Center(
              child: Text('Product grid coming soon!'),
            ),
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
            //onTap: () => _showUserProfile(),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: widget.user!.photoURL != null 
                ? NetworkImage(widget.user!.photoURL!)
                : null,
              backgroundColor: Colors.grey[300],
              child: widget.user!.photoURL == null 
                ? Icon(Icons.person, size: 50, color: Colors.grey[600])
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
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/login/login_init.dart';
import 'package:shopping_app/model/product.dart';
import 'package:shopping_app/model/user.dart'; // Import the new product file

class HomeScreen extends StatefulWidget {
  final UserModel? user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = "random";
  int _cartItemCount = 0; // take from cart ? or db
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

  Widget _buildHeader() { //gonna put in setting
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              decoration: InputDecoration(
                prefix: SizedBox(width: 12,),
                hintText: _searchQuery,
                hintStyle: TextStyle(color: Colors.grey[600]),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon( //may add on tap function
                      Icons.search, color: Colors.grey[600],
                      ),
                    ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.isEmpty? "random products?" : value;
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

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // Swiped Left: go to next category if possible
          setState(() {
            if (_selectedCategoryIndex < _categories.length - 1) {
              _selectedCategoryIndex++;
            }
          });
        } else if (details.primaryVelocity! > 0) {
          // Swiped Right: go to previous category if possible
          setState(() {
            if (_selectedCategoryIndex > 0) {
              _selectedCategoryIndex--;
            }
          });
        }
      },
      child: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard( //use category to query product
            product: products[index],
            onTap: () => _showProductDetails(products[index]),
            onAddToCart: () {
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
          );
        },
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
        BottomNavigationBarItem( // may not need
          icon: Icon(Icons.local_shipping),
          label: "Delivery",
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
      builder: (context) => ProductDetailsModel(
        product: product,
        onAddToCart: () {
          Navigator.pop(context);
          setState(() {
            _cartItemCount++;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Added to cart!")),
          );
        },
        onBuyNow: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Proceeding to checkout...")),
          );
        },
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
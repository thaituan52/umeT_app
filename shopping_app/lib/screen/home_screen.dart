import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/model/category.dart';
import 'package:shopping_app/model/product.dart';
import 'package:shopping_app/model/user.dart'; // Import the new product file
import 'package:shopping_app/screen/product_detail_screen.dart';
import 'package:shopping_app/service/product_service.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = "search";
  int _cartItemCount = 0; // take from cart ? or db
  //List<Category> _categories = [Category(id: 0, name: "All", isActive: true)];
  List<Category>? _cacheCategories;
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _selectedIndex == 0 ? _buildMainContent() : _buildOtherScreen(),
      
    );
  }

Widget _buildMainContent() {
  return SafeArea(
    child: Column(
      children: [
        _buildSearchBar(),
        _buildCategoryTabs(),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0 && _selectedCategoryIndex < (_cacheCategories?.length ?? 1) - 1) {
                setState(() {
                  _selectedCategoryIndex++;
                });
              } else if (details.primaryVelocity! > 0 && _selectedCategoryIndex > 0) {
                setState(() {
                  _selectedCategoryIndex--;
                });
              }
            },
            child: SizedBox(
              //color: Colors.grey,
              width: double.infinity,
              child: ProductGridWidget(
                      categoryId: _selectedCategoryIndex,
                      searchQuery: _searchQuery,
                      user: widget.user,
                      cartItemCount: _cartItemCount,
                      onAddToCartExternal: (product) {
                        setState(() {
                        _cartItemCount++;
                        });
                      },
                ),
              ), 
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
                  _searchQuery = value.isEmpty? "search" : value;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
  return FutureBuilder<List<Category>>(
    future: _getCategoriesWithAll(),
    builder: (context, snapshot) {
      // if (snapshot.connectionState == ConnectionState.waiting) {
      //   return SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
      //   //debug purpose
      // }
      
      if (!snapshot.hasData) {
        return SizedBox(height: 60);
      }
      
      List<Category> categories = snapshot.data!;
      
      return SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
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
                  categories[index].name,
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
    },
  );
}

Future<List<Category>> _getCategoriesWithAll() async {
  if(_cacheCategories != null) {
    return _cacheCategories!;
  }

  final categories = await ProductService.getCategories();
  _cacheCategories = [Category(id: 0, name: "All", isActive: true)] + categories;
  return _cacheCategories!;
}

//   Widget _buildProductGrid() {
//   return FutureBuilder<List<Product>>(
//     future: ProductService.getProducts(
//       categoryId: _selectedCategoryIndex == 0 ? null : _selectedCategoryIndex,
//       query: _searchQuery == "search" ? '' : _searchQuery,
//     ),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return Center(child: CircularProgressIndicator());
//       } else if (snapshot.hasError) {
//         return Center(child: Text('Error: ${snapshot.error}'));
//       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//         return Center(child: Text('No products found.'));
//       } else {
//         List<Product> products = snapshot.data!;
//         return GridView.builder(
//             padding: EdgeInsets.all(8),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.65,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               return ProductCard(
//                 product: products[index],
//                 onTap: () => _navigateToProductDetail(products[index], widget.user),
//                 onAddToCart: () {
//                   setState(() {
//                     _cartItemCount++;
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Added to cart!"),
//                       duration: Duration(seconds: 1),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//       }
//     },
//   );
// }




// Update this method in your HomeScreen class
void _navigateToProductDetail(Product product, UserModel? user) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailScreen(
        product: product,
        user: user!,
        cartItemCount: _cartItemCount, // Pass the cart count here
        onAddToCart: () {
          setState(() {
            _cartItemCount++;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Added to cart")),
          );
        },
        onBuyNow: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Proceeding to checkout...")),
          );
        },
      ),
    ),
  );
}

}
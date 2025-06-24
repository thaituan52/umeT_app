import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/product.dart';
import 'package:shopping_app/models/user.dart'; // Import the new product file
import 'package:shopping_app/service/product_service.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: _buildMainContent(),
      
    );
  }

Widget _buildMainContent() {
  return SafeArea(
    child: Column(
      children: [
        _buildSearchBar(),
        _buildCategoryTabs(),
        Expanded(
            child: CustomScrollView(
              slivers: [

                SliverToBoxAdapter(
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
                    child: Container(
                      //color: Colors.grey,
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
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

}
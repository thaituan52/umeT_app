import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart'; 
import '../widgets/product_grid.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Consumer here to rebuild the body when HomeController's state changes.
    // This allows the search bar and category tabs to update, and the ProductGridWidget
    // will also react to HomeController's changes internally.
    return Consumer2<HomeController, CartController>( // <--- Use Consumer2 to get both controllers
      builder: (context, homeController, cartController, child) { // Access both controllers here
        // If you need the UserModel itself, get it from the homeController
        //final UserModel? currentUser = homeController.user;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(homeController),
                _buildCategoryTabs(homeController),
                // Wrap ProductGridWidget with Expanded to allow it to take available space
                Expanded(
                  child: CustomScrollView( // Maintain CustomScrollView for potential future scroll effects
                    slivers: [
                      SliverToBoxAdapter(
                        // Add GestureDetector here to handle horizontal drag for category selection
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque, // Ensures the whole area is tappable/draggable
                          onHorizontalDragEnd: (details) {
                            homeController.handleHorizontalDrag(details);
                          },
                          child: Container(
                            // It's usually not good practice to give a minHeight equal to screen height
                            // unless you have specific reasons, as it can cause overflow if content is larger.
                            // The Expanded widget above handles available space.
                            // constraints: BoxConstraints(
                            //   minHeight: MediaQuery.of(context).size.height,
                            // ),
                            child: ProductGridWidget(
                              homeController: homeController, // Pass HomeController
                              cartController: cartController, // Pass CartController
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(HomeController controller) {
    // No changes here, as it already uses the passed controller
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 158, 129, 163),
      ),
      child: TextField(
        controller: TextEditingController(text: controller.searchQuery == "search" ? "" : controller.searchQuery), // Set initial value from controller
        decoration: InputDecoration(
          prefix: const SizedBox(width: 12),
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.grey[600]),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search,
                color: Colors.grey[600],
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          controller.updateSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildCategoryTabs(HomeController controller) {
    // No changes here, as it already uses the passed controller
    if (controller.isLoadingCategories) {
      return const SizedBox(
          height: 60, child: Center(child: CircularProgressIndicator()));
    }

    if (controller.categories.isEmpty) {
      return const SizedBox(height: 60);
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              controller.selectCategory(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 158, 129, 163)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
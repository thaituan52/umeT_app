import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../models/user.dart';
import '../widgets/product_grid.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      user: widget.user,
      onStateUpdate: () {
        setState(() {});
      },
    );
    _controller.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildMainContent(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryTabs(),
          _buildProduct(context),
        ],
      ),
    );
  }

  Widget _buildProduct(BuildContext context) {
    return Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                _controller.handleHorizontalDrag(details);
              },
              child: Container(
                width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                child: ProductGridWidget(
                  user: widget.user,
                  controller: _controller, // add controller here?
                ),
              ),
            ),
              ),
            ],
            
          ),
        );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 158, 129, 163),
      ),
      child: TextField(
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
          _controller.updateSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    if (_controller.isLoadingCategories) {
      return const SizedBox(
          height: 60, child: Center(child: CircularProgressIndicator()));
    }

    if (_controller.categories.isEmpty) {
      return const SizedBox(height: 60);
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _controller.categories.length,
        itemBuilder: (context, index) {
          final category = _controller.categories[index];
          final isSelected = _controller.selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              _controller.selectCategory(index);
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
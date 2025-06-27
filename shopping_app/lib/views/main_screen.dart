import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/controllers/main_screen_controller.dart';
import 'package:shopping_app/models/user.dart';
import 'package:shopping_app/views/cart_screen.dart';
import 'package:shopping_app/views/home_screen.dart';
import 'package:shopping_app/views/profile_screen.dart';


class MainScreen extends StatefulWidget {
  final UserModel? user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final List<Widget> _screen = [];

  @override
  void initState() {
    super.initState();
    _screen.addAll([
      HomeScreen(user: widget.user),
      CartScreen(user: widget.user!),
      ProfileScreen(user: widget.user),
    ]);
  }


  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MainScreenController>(context);
    final List<Widget> pages = [
      HomeScreen(user: widget.user),
      CartScreen(user: widget.user!),
      ProfileScreen(user: widget.user),
    ];
    return Scaffold(
      body: IndexedStack(
        index: controller.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.currentIndex,
        onTap: controller.setIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "You"),
        ]
      ),
    );
  }

}
import 'package:flutter/material.dart';
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
  int _selectedIndex = 0;

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

  void _onScreenTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onScreenTapped,
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
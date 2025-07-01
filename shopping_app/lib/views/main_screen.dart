import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/cart_screen.dart';
import '../views/home_screen.dart';
import '../views/profile_screen.dart';
import '../controllers/cart_controller.dart'; // Import CartController for Provider

// The user is available via Provider from the HomeController.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // The list of screens is now stateless and doesn't need the user parameter.
  // We can define it here and it will get its dependencies from the Provider.
  final List<Widget> _screen = [
    const HomeScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  void _onScreenTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // You can access the user model here if needed, but the child screens will
    // get it directly from the HomeController using Provider.
    //final UserModel? currentUser = Provider.of<HomeController>(context).user;

    return Scaffold(
      body: _screen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onScreenTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(
            icon: Consumer<CartController>(
              builder: (context, cartController, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_cart,),
                    if (cartController.totalCartQuantity  > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${cartController.totalCartQuantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: "Cart",
          ),

          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "You"),
        ],
      ),
    );
  }

}
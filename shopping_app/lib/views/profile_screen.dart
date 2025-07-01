import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';


import '../models/user.dart';
import '../controllers/home_controller.dart';



class ProfileScreen extends StatelessWidget { 
  const ProfileScreen({super.key});


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

  // Handle logout logic (remains the same)
  void _handleLogout(BuildContext context) async {
    try {
      bool success = await signOutFromGoogle();
      if (success) {
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
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
    //Access the HomeController from the widget tree 
    final homeController = Provider.of<HomeController>(context);
    final UserModel? user = homeController.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      //Pass the user to the main content builder
      body: _buildMainContent(context, user),
    );
  }

  //Pass context and user down to helper methods
  Widget _buildMainContent(BuildContext context, UserModel? user) {
    return SafeArea(
      child: Column(
        children: [
          //Pass the user down
          _buildHeader(context, user),
          Expanded(
            child: ListView( // Changed to ListView for simple scrolling content
              children: [
                //Pass context to the search bar method
                _buildSearchBar(context),
                // You can uncomment this if you need to show a product grid on the profile screen
                // Consumer<HomeController>(
                //   builder: (context, controller, child) {
                //     return ProductGridWidget(
                //       user: user,
                //       controller: controller,
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Pass context and user down
  Widget _buildHeader(BuildContext context, UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 158, 129, 163),
      ),
      child: Row(
        children: [
          GestureDetector(
            // <--- CHANGE: Pass context to the showUserProfile method
            onTap: () => _showUserProfile(context, user),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              backgroundColor: Colors.grey[300],
              child: user?.photoURL == null
                  ? Icon(Icons.person, size: 20, color: Colors.grey[600])
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help, color: Colors.white),
            onPressed: () { /* Handle help button press */ },
            tooltip: 'Help',
          ),
          const SizedBox(width: 12),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 56,
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuButton(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuButton(
            context: context,
            icon: Icons.shopping_bag_outlined,
            title: 'Your orders',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const YourOrdersScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuButton(
            context: context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Credit balance',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreditBalanceScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuButton(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddressesScreen()),
            ),
          ),
        ],
      ),
    );
  }

  //Pass context and user down
  void _showUserProfile(BuildContext context, UserModel? user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                backgroundColor: Colors.grey[300],
                child: user?.photoURL == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.identifier ?? 'No email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
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

// --------------------------------------------------------------------------
// Create these placeholder screens for the navigation to work without errors.
// --------------------------------------------------------------------------

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}

class YourOrdersScreen extends StatelessWidget {
  const YourOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: const Center(child: Text('Your Orders Screen')),
    );
  }
}

class CreditBalanceScreen extends StatelessWidget {
  const CreditBalanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credit Balance')),
      body: const Center(child: Text('Credit Balance Screen')),
    );
  }
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Addresses')),
      body: const Center(child: Text('Addresses Screen')),
    );
  }
}
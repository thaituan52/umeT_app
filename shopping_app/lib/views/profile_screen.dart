import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/views/login_screen.dart';
import 'package:shopping_app/models/user.dart';

import '../widgets/product_grid.dart'; // Import the new product file

class ProfileScreen extends StatefulWidget {
  final UserModel? user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _cartItemCount = 0; // take from cart ? or db
  //List<Category> _categories = [Category(id: 0, name: "All", isActive: true)];

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
      body: _buildMainContent(),
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

Widget _buildMainContent() {
  return SafeArea(
    child: Column(
      children: [
        _buildHeader(),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(
                child: ProductGridWidget(
                        categoryId: 0,
                        searchQuery: '',
                        user: widget.user,
                        cartItemCount: _cartItemCount,
                        onAddToCartExternal: (product) {
                          setState(() {
                          _cartItemCount++;
                          });
                        },
                ), 
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
            child: Text(
                  widget.user?.displayName ?? 'User',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
          ),

          IconButton(
            icon: Icon(Icons.help, color: Colors.white),
            onPressed: () => (),
            tooltip: 'Settings',
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
    // String? badge,
    // String? trailing,
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

  Widget _buildSearchBar() {
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
                      MaterialPageRoute(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                ),
                  _buildDivider(),
                  _buildMenuButton(
                    context: context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your orders',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // _buildDivider(),
                  // _buildMenuButton(
                  //   icon: Icons.star_border,
                  //   title: 'Your reviews',
                  //   onTap: () {},
                  // ),
                  // _buildDivider(),
                  // _buildMenuButton(
                  //   icon: Icons.local_offer_outlined,
                  //   title: 'Coupons & offers',
                  //   onTap: () {},
                  // ),
                  _buildDivider(),
                  _buildMenuButton(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Credit balance',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildMenuButton(
                    context: context,
                    icon: Icons.location_on_outlined,
                    title: 'Addresses',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ],
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
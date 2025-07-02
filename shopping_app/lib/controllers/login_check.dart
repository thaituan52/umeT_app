import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/views/login_screen.dart';
import 'package:shopping_app/models/user.dart';
import 'package:shopping_app/views/main_screen.dart';
import '../controllers/cart_controller.dart';
import '../controllers/home_controller.dart';


//TODO: Making it change to other user during the log session
class LoginCheck extends StatefulWidget { 
  const LoginCheck({super.key});

  @override
  State<LoginCheck> createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck> {
  //Store the UID of the last known user.
  String? _lastUserId;

  @override
  void didUpdateWidget(covariant LoginCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This is a good place to listen for changes if needed, but the builder is more direct.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final currentUser = snapshot.data;
          final currentUserId = currentUser?.uid;

          //React to user changes within the StreamBuilder's builder.
          // This ensures the logic runs every time the stream emits a new value.
          if (currentUserId != null && _lastUserId != currentUserId) {
            // A new user has just logged in, or the user has changed.
            // This is the perfect time to load user-specific data.
            debugPrint('User changed from $_lastUserId to $currentUserId. Loading cart...');

            // Get the controllers from the context.
            final homeController = context.read<HomeController>();
            final cartController = context.read<CartController>();

            // Update the user property on the controllers.
            final currentUserModel = UserModel.fromFirebaseUser(currentUser!);
            homeController.user = currentUserModel;
            cartController.user = currentUserModel;

            
            // Schedule the loadCart() call to run after the build is complete.
            // This prevents the 'setState() during build' error.
            Future.microtask(() async {
              // await homeController.resetState();
              await cartController.loadCart();
              // No need for setState here if loadCart() calls notifyListeners().
              // notifyListeners() will cause the Consumer widgets to rebuild.
            });

            //Update the state with the new user's UID.
            // This will prevent the load from running again on subsequent builds for the same user.
            _lastUserId = currentUserId;
          } else if (currentUserId == null) {
            // User has logged out. Reset the state.
            debugPrint('User logged out.');
            //_lastUserId = null;

            final homeController = context.read<HomeController>();
            Future.microtask(() => homeController.resetState());
          }
          // <--- END NEW LOGIC --->

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // User is authenticated, show the MainScreen.
            return const MainScreen();
          } else {
            // No user authenticated, show the LoginScreen.
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/widgets/login_button.dart';
import 'package:shopping_app/controllers/login_controller.dart'; 


class LoginScreen extends StatelessWidget { 
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to access the LoginController and rebuild the UI when its state changes.
    return Consumer<LoginController>(
      builder: (context, controller, child) {
        //Display a SnackBar for errors from the controller ---
        //We use a post-frame callback to avoid errors from calling setState during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.errorMessage!),
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: controller.clearError, // Call controller method to clear the error
                ),
              ),
            );
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 158, 129, 163),
            toolbarHeight: 80,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  child: Text('umeT', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.green),
                    SizedBox(width: 8),
                    Text('All data is not encrypted!?', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  debugPrint('Settings button pressed');
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Pass the controller's state and methods to your UI widgets
              _buildLoginButtons(context, controller),
              SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  // Refactored method to build the buttons using the controller
  Container _buildLoginButtons(BuildContext context, LoginController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginButton(
            method: 'Apple',
            selectedMethod: controller.selectedMethod,
            onMethodSelected: (method) => controller.handleSignIn(method!), 
            icon: Icons.apple,
            iconColor: Colors.white,
            isLoading: controller.isLoading && controller.selectedMethod == 'Apple',
          ),
          SizedBox(height: 16.0),
          LoginButton(
            method: 'Google',
            selectedMethod: controller.selectedMethod,
            onMethodSelected: (method) => controller.handleSignIn(method!), 
            icon: Icons.g_mobiledata,
            iconColor: Colors.accents[3],
            isLoading: controller.isLoading && controller.selectedMethod == 'Google',
          ),
          SizedBox(height: 16.0),
          LoginButton(
            method: 'Facebook',
            selectedMethod: controller.selectedMethod,
            onMethodSelected: (method) => controller.handleSignIn(method!), 
            icon: Icons.facebook,
            iconColor: Colors.blue,
            isLoading: controller.isLoading && controller.selectedMethod == 'Facebook',
          ),
          SizedBox(height: 16.0),
          LoginButton(
            method: 'Email',
            selectedMethod: controller.selectedMethod,
            onMethodSelected: (method) => controller.handleSignIn(method!), 
            icon: Icons.email,
            iconColor: Colors.red,
            isLoading: controller.isLoading && controller.selectedMethod == 'Email',
          ),
          SizedBox(height: 16.0),
          LoginButton(
            method: 'Phone',
            selectedMethod: controller.selectedMethod,
            onMethodSelected: (method) => controller.handleSignIn(method!), 
            icon: Icons.phone,
            iconColor: Colors.green,
            isLoading: controller.isLoading && controller.selectedMethod == 'Phone',
          ),
          SizedBox(height: 24),
          TextButton(
            onPressed: () {
              debugPrint('Trouble signing in clicked');
            },
            child: Text(
              'Trouble signing in?',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              children: [
                TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Terms of Use',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shopping_app/cus_wid/login_button.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/screen/home_screen.dart'; //Implement Google Sign-In
import 'package:shopping_app/model/user.dart'; // Import the login screen
import 'package:shopping_app/service/auth_service.dart'; // Import the UserModel

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _selectedMethod;
  bool _isLoading = false; // Used to check if the sign-in is loading or not
  
  Future<void> _onMethodSelected(String? method) async {
    setState(() {
      _selectedMethod = method;
      _isLoading = true;
    });
    print('Selected method: $method');

    try {
      UserModel? userModel;
      switch (method) {
        case 'Apple':
          // Handle Apple sign-in
          print('Apple sign-in selected');
          break;
        case 'Google':
          // Handle Google sign-in
          userModel = await AuthService.handleGoogleSignIn();
          // Implement Google Sign-In logic here
          break;
        case 'Facebook':
          // Handle Facebook sign-in
          print('Facebook sign-in selected');
          break;
        case 'Email':
          // Handle Email sign-in
          print('Email sign-in selected');
          break;
        case 'Phone':
          // Handle Phone sign-in
          print('Phone sign-in selected');
          break;
        default:
          print('Unknown method selected');
      }

      if (userModel != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: userModel),
          ),
        );
      }
    } catch (e) {
      _showMessage('Error handling $method sign-in: $e');
    } finally {
      setState(() {
      _isLoading = false; // Reset loading state after handling the method
      });
    }
    //Should make a way to log in via the selected method
  }

  // Handle Google Sign-In
  // Future<UserModel?> _handleGoogleSignIn() async {
  //   try {
  //     final UserCredential? userCredential = await signInWithGoogle();

  //     if (userCredential != null && userCredential.user != null) {
  //       // Sign-in successful
  //       _showMessage('Signed in as ${userCredential.user!.email}');
  //       //print(userCredential.toString()); debug only
  //       final userModel = UserModel.fromFirebaseUser(userCredential.user!);

  //       //save userModel to database if needed
        


  //       return userModel; // Return the UserModel instance
  //     } else {
  //       // Sign-in failed
  //       _showMessage('Google sign-in failed');
  //       return null;
  //     }
  //   } catch (e) {
  //     // Handle sign-in error
  //     _showMessage('Error signing in with Google: $e');
  //     return null;
  //   }
  // }


  // // Sign in with Google
  // Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();

  //     if (googleAccount == null) return null; // User cancelled the sign-in

  //     final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     return await FirebaseAuth.instance.signInWithCredential(credential);
  //   } on Exception catch (e) {
  //     // Handle sign-in error
  //     print('Error signing in with Google: $e');
  //     return null;
  //   }
  // }

  // Future<bool> signOutFromGoogle() async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     await GoogleSignIn().signOut();
  //     return true; // Sign-out successful
  //   } catch (e) {
  //     print('Error signing out from Google: $e');
  //     return false; // Sign-out failed
  //   }
  // }

  // Show a message in a SnackBar


  Future<UserModel?> _handleFacebookSignIn() async {
    return null;
  }

  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 158, 129, 163),
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            //Navigator.pop(context);
            print('Quit button pressed');
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Text('umeT', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange,)),
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
              // Navigate to settings page
              print('Settings button pressed');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          loginWay(),
          SizedBox(height: 20), // Add some space between the buttons and the footer
          _buildFooter(), //Gonna change later (vibe coding)
        ],
      ),
    );
  }

  Container loginWay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginButton(
            method: 'Apple',
            selectedMethod: _selectedMethod,
            onMethodSelected: _onMethodSelected,
            icon: Icons.apple,
            iconColor: Colors.white,
            isLoading: _isLoading && _selectedMethod == 'Apple'
          ),

          SizedBox(height: 16.0),
          
          LoginButton(
            method: 'Google',
            selectedMethod: _selectedMethod,
            onMethodSelected: _onMethodSelected,
            icon: Icons.g_mobiledata,
            iconColor: Colors.accents[3], // Use a color from the accent palette
            isLoading: _isLoading && _selectedMethod == 'Google', // Show loading state for Google sign-in
          ),

          SizedBox(height: 16.0),

          LoginButton(
            method: 'Facebook',
            selectedMethod: _selectedMethod,
            onMethodSelected: _onMethodSelected,
            icon: Icons.facebook,
            iconColor: Colors.blue,
            isLoading: _isLoading && _selectedMethod == 'Facebook', // Show loading state for Facebook sign-in
          ),

          SizedBox(height: 16.0),

          LoginButton(
            method: 'Email',
            selectedMethod: _selectedMethod,
            onMethodSelected: _onMethodSelected,
            icon: Icons.email,
            iconColor: Colors.red,
            isLoading: _isLoading && _selectedMethod == 'Email', // Show loading state for Email sign-in
          ),

          SizedBox(height: 16.0),

          LoginButton(
            method: 'Phone',
            selectedMethod: _selectedMethod,
            onMethodSelected: _onMethodSelected,
            icon: Icons.phone,
            iconColor: Colors.green,
            isLoading: _isLoading && _selectedMethod == 'Phone', // Show loading state for Phone sign-in
          ),

          SizedBox(height: 24),
          
          TextButton( //temporary button to make it look similar to the original design, gonna add logic later
            onPressed: () {
              print('Trouble signing in clicked');
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
          // SizedBox(height: 16),
          // Container(
          //   width: 134,
          //   height: 5,
          //   decoration: BoxDecoration(
          //     color: Colors.black,
          //     borderRadius: BorderRadius.circular(2.5),
          //   ),
          // ),
        ],
      ),
    );
  }

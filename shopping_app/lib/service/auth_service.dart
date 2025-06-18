// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/model/user.dart';

//need postAPI to check the api need

class AuthService {
  static const String _apiBaseUrl = 'http://10.0.2.2:8000'; 

  // Handle Google Sign-In with backend save
  static Future<UserModel?> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();
      if (googleAccount == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleAccount.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2. Sign in to Firebase
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user == null) return null;

      // 3. Create UserModel from Firebase user
      final userModel = UserModel.fromFirebaseUser(userCredential.user!);

      // 4. Save to backend database
      await _saveUserToBackend(userModel);

      return userModel;
    } catch (e) {
      print('Google sign-in error: $e');
      rethrow;
    }
  }

  // Save user to your FastAPI backend
  static Future<void> _saveUserToBackend(UserModel user) async {
    try {
      final payload = {
        "uid": user.uid,
        "provider": user.provider,
        "identifier": user.identifier,
        "photo_url": user.photoURL,
        "display_name": user.displayName,
        "is_active": true,
      };

      // print('Sending payload: $payload');
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      // Debugging output
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save user: ${response.body}');
      }
    } catch (e) {
      print('Error saving user to backend: $e');
      rethrow;
    }
  }

  // Add similar methods for other auth providers:
  // static Future<UserModel?> handleFacebookSignIn() {...}
  // static Future<UserModel?> handleEmailSignIn() {...}
  // static Future<UserModel?> handlePhoneSignIn() {...}
}
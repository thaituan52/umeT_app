import 'package:flutter/material.dart';
import '../service/user_service.dart'; // Make sure this import path is correct

class LoginController extends ChangeNotifier {
  // Dependency Injection: AuthService is passed in, not created inside.
  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedMethod; // To track which specific login button is loading

  // Getters to expose the state to the UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedMethod => _selectedMethod;

  // Constructor: Requires an AuthService instance
  LoginController({required AuthService authService}) : _authService = authService;

  // Method to handle sign-in attempts for different methods
  Future<void> handleSignIn(String method) async {
    // Set the specific method that is currently loading
    _selectedMethod = method;
    _setLoading(true); // Start loading state
    clearError();      // Clear any previous errors

    try {
      switch (method) {
        case 'Apple':
          // TODO: Implement Apple Sign-In logic in AuthService
          // await _authService.signInWithApple();
          _setErrorMessage('Apple sign-in is not yet implemented.');
          break;
        case 'Google':
          await _authService.handleGoogleSignIn();
          // IMPORTANT: We do NOT navigate here.
          // The FirebaseAuth.instance.authStateChanges() stream (watched by LoginCheck)
          // will detect the successful login and automatically rebuild the UI to MainScreen.
          break;
        case 'Facebook':
          // TODO: Implement Facebook Sign-In logic in AuthService
          // await _authService.signInWithFacebook();
          _setErrorMessage('Facebook sign-in is not yet implemented.');
          break;
        case 'Email':
          _setErrorMessage('Email sign-in is not yet implemented.');
          // TODO: Implement email/password login flow (e.g., show a dialog)
          break;
        case 'Phone':
          _setErrorMessage('Phone sign-in is not yet implemented.');
          // TODO: Implement phone sign-in flow
          break;
        default:
          _setErrorMessage('Unknown sign-in method: $method');
          break;
      }
    } catch (e) {
      // Catch any errors during the sign-in process
      _setErrorMessage('Error signing in with $method: ${e.toString()}');
      debugPrint('Sign-In Error ($method): $e');
    } finally {
      // Reset loading state regardless of success or failure
      _setLoading(false);
      _selectedMethod = null; // Clear the selected method once loading is done
    }
  }

  // Helper method to clear the error message (e.g., after a SnackBar is dismissed)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private helper to manage the overall loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  // Private helper to set an error message
  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  // You might want to add a signOut method here as well, if your app's flow allows signing out from main screens
  // and then returning to the login screen without going through LoginCheck from scratch.
  // Future<void> signOut() async {
  //   try {
  //     await _authService.signOut();
  //     // The FirebaseAuth stream will update, and LoginCheck will automatically switch to LoginScreen.
  //   } catch (e) {
  //     debugPrint('Error signing out: $e');
  //     _setErrorMessage('Failed to sign out: ${e.toString()}');
  //   }
  // }
}
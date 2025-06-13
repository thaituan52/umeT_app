import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  //compulsory vars
  final String uid; //UserUID
  final String provider; //Google, Facebook, etc
  final String identifier; //identifier used to login may change later
    final String? photoURL; //should have or gonna be a blank icon
  //optional vars
  final String? email; 
  final String? displayName;
  final String? phoneNumber;
  final String? password; //only when use email/phone
  
  //time vars
  final DateTime createdAt; //when the user is created
  final DateTime? updatedAt; //when the user is updated
  final DateTime lastLogin; //when the user last logged in
  final bool isActive; //if the user is active or not, may remove later

  UserModel({
    required this.uid,
    required this.provider,
    required this.identifier,
    this.photoURL,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.password,
    required this.createdAt,
    this.updatedAt,
    required this.lastLogin,
    this.isActive = true, //default to true
  });

  // Factory constructor to create a UserModel from Firebase user
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    String provider = 'google'; // Default to Google, can be changed based on the provider
    if (firebaseUser.providerData.isNotEmpty) {
      final providerId = firebaseUser.providerData[0].providerId; // Get the provider ID
      switch (providerId) {
      case 'google.com':
        provider = 'google';
        break;
      case 'facebook.com':
        provider = 'facebook';
        break;
      case 'password':
        provider = 'email';
        break;
      // Add more cases for other providers if needed
      default:
        provider = 'phone'; // Default to phone if no provider matches
      }
    }
    return UserModel(
      uid: firebaseUser.uid,
      provider: provider,
      // Use email or phone number as identifier, fallback to uid, gonna check if need in the future
      identifier: firebaseUser.email ?? firebaseUser.phoneNumber ?? firebaseUser.uid, 
      photoURL: firebaseUser.photoURL,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      phoneNumber: firebaseUser.phoneNumber,
      password: null, // Password is not available from Firebase user
      createdAt: DateTime.now(), // Set to current time, can be changed later
      updatedAt: null, // Initially null, can be updated later
      lastLogin: DateTime.now(), // Set to current time, can be changed later
    );
  }

  //safe to do: make function to convert UserModel to/ from JSON
  // factory UserModel.fromJson(Map<String, dynamic> json) {

  // }

}
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  //compulsory vars
  final String uid; //Firbase UID
  final String provider; //Google, Facebook, etc
  final String identifier; //username
  final String? photoURL; //should have or gonna be a blank icon
  final String? displayName;
  
  //optional vars
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
    this.displayName,
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
      displayName: firebaseUser.displayName,
      password: null, // Password is not available from Firebase user
      createdAt: DateTime.now(), // Set to current time, can be changed later
      updatedAt: null, // Initially null, can be updated later
      lastLogin: DateTime.now(), // Set to current time, can be changed later
    );
  }

  //Vibe coding: may not use but this is here in case we need it later
  //safe to do: make function to convert UserModel to/ from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      provider: json['provider'] as String,
      identifier: json['identifier'] as String,
      photoURL: json['photoURL'] as String?,
      displayName: json['displayName'] as String?,
      password: json['password'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json.containsKey('updatedAt') ? DateTime.parse(json['updatedAt'] as String) : null,
      lastLogin: DateTime.parse(json['lastLogin'] as String),
      isActive: json['isActive'] as bool? ?? true, // Default to true if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'provider': provider,
      'identifier': identifier,
      'photoURL': photoURL,
      'displayName': displayName,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? uid,
    String? provider,
    String? identifier,
    String? photoURL,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      provider: provider ?? this.provider,
      identifier: identifier ?? this.identifier,
      photoURL: photoURL ?? this.photoURL,
      displayName: displayName ?? this.displayName,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, provider: $provider, identifier: $identifier, photoURL: $photoURL, displayName: $displayName, createdAt: $createdAt, updatedAt: $updatedAt, lastLogin: $lastLogin, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid; //uid must be unique
  }

  @override
  int get hashCode => uid.hashCode; //hashCode based on uid

}
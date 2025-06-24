import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/views/login_screen.dart';
import 'package:shopping_app/models/user.dart';
import 'package:shopping_app/views/main_screen.dart';



class LoginCheck extends StatelessWidget {
  const LoginCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainScreen(
              user: UserModel.fromFirebaseUser(snapshot.data!),
            );
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}

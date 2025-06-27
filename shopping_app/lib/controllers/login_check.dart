import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/views/login_screen.dart';
import 'package:shopping_app/models/user.dart';
import 'package:shopping_app/views/main_screen.dart';

import 'main_screen_controller.dart';



class LoginCheck extends StatelessWidget {
  const LoginCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
            return ChangeNotifierProvider<MainScreenController>(
            create: (_) => MainScreenController(),
            child: snapshot.hasData
                ? MainScreen(user: UserModel.fromFirebaseUser(snapshot.data!))
                : LoginScreen(),
          );
        },
      ),
    );
  }
}

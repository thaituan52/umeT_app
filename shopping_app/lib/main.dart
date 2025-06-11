import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 92, 223, 140)),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Text('TEMU', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange, fontFamily: 'RobotoMono')),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, color: Colors.green),
                SizedBox(width: 8),
                Text('All data is encrypted!?', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
            ], 
          ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            //Navigator.pop(context);
            print('Quit button pressed');
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Implement Google Sign-In logic here
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './controllers/login_check.dart';
import './controllers/home_controller.dart';
import './controllers/cart_controller.dart';
import './controllers/login_controller.dart'; // Make sure to import this
import './service/cart_service.dart';
import './service/categories_service.dart';
import './service/product_service.dart';
import './service/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    //Wrap your entire app with MultiProvider here!
    MultiProvider(
      providers: [
        // Provide your services first, so controllers can use them.
        // These are typically singletons, so no need for ChangeNotifier.
        Provider(create: (_) => CartService()),
        Provider(create: (_) => CategoriesService()),
        Provider(create: (_) => ProductService()),
        Provider(create: (_) => AuthService()),

        // Provide your controllers, injecting their dependencies.
        // They are created once at the start of the app - loginCheck
        ChangeNotifierProvider<HomeController>(
          create: (context) => HomeController(
            categoriesService: context.read<CategoriesService>(),
            productService: context.read<ProductService>(),
          ),
        ),
        ChangeNotifierProvider<CartController>(
          create: (context) => CartController(
            cartService: context.read<CartService>(),
          ),
        ),
        ChangeNotifierProvider<LoginController>(
          create: (context) => LoginController(
            authService: context.read<AuthService>(),
          ),
        ),
      ],
      child: const MyApp(), // Your main app widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 92, 223, 140)),
        fontFamily: 'Roboto',
      ),
      home: const LoginCheck(),
      debugShowCheckedModeBanner: false,
    );
  }
}
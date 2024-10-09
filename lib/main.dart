// main.dart
import 'package:flutter/material.dart';
import 'package:celiapp/screens/loading_screen.dart';
import 'package:celiapp/screens/home_screen.dart';
import 'package:celiapp/screens/login_screen.dart';
import 'package:celiapp/screens/register_screen.dart';
import 'package:celiapp/screens/user_settings_screen.dart';
import 'package:celiapp/screens/recommended_products_screen.dart';
import 'package:celiapp/screens/map_screen.dart';
import 'package:celiapp/screens/user_profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CeliApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/home': (context) =>  HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/user_settings': (context) => const UserSettingsScreen(), //
        '/recommended_products': (context) => const RecommendedProductsScreen(),
        '/map': (context) => const MapScreen(),
          '/user_profile': (context) => UserProfileScreen(),
      },
    );
  }
}

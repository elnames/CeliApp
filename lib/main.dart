import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/product_management_screen.dart';
import 'screens/store_management_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/map_screen.dart';
import 'constants/app_colors.dart';
import 'theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'CeliApp',
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.lightBg100,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
            ),
          ),
          darkTheme: ThemeData(
            primaryColor: AppColors.darkPrimary,
            scaffoldBackgroundColor: AppColors.darkBg100,
            colorScheme: ColorScheme.dark(
              primary: AppColors.darkPrimary,
              secondary: AppColors.darkAccent,
            ),
          ),
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/home',
          routes: {
            '/home': (context) => HomeScreen(),
            '/profile': (context) => UserProfileScreen(),
            '/admin': (context) => AdminScreen(),
            '/product_management': (context) => ProductManagementScreen(),
            '/tienda_management': (context) => StoreManagementScreen(),
            '/product_detail': (context) {
              final product = ModalRoute.of(context)!.settings.arguments as dynamic;
              return ProductDetailScreen(product: product);
            },
            '/catalog': (context) => CatalogScreen(),
            '/map': (context) => MapScreen(stores: []),
          },
        );
      },
    );
  }
}

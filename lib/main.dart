import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/user_settings_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/product_edit_screen.dart';
import 'screens/admin_screen.dart'; // Pantalla de administración (CRUD)
import 'screens/tienda_list_screen.dart'; // Pantalla de lista de tiendas
import 'screens/tienda_form_screen.dart'; // Pantalla de formulario de tiendas
import 'screens/tienda_edit_screen.dart'; // Pantalla de edición de tiendas
import 'firebase_options.dart';
import 'package:celiapp/widgets/apps_colors.dart';
import 'screens/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeModel, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeModel.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: AppColors.lightPrimary100,
                secondary: AppColors.lightAccent100,
                background: AppColors.lightBg100,
              ),
              scaffoldBackgroundColor: AppColors.lightBg100,
              textTheme: TextTheme(
                titleLarge: TextStyle(color: AppColors.lightText100),
                bodyMedium: TextStyle(color: AppColors.lightText200),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.dark(
                primary: AppColors.darkPrimary100,
                secondary: AppColors.darkAccent100,
                background: AppColors.darkBg100,
              ),
              scaffoldBackgroundColor: AppColors.darkBg100,
              textTheme: TextTheme(
                titleLarge: TextStyle(color: AppColors.darkText100),
                bodyMedium: TextStyle(color: AppColors.darkText200),
              ),
            ),
            initialRoute: '/home',
            routes: {
              '/home': (context) => HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
              '/map': (context) => MapScreen(),
              '/settings': (context) => SettingsScreen(),
              '/profile': (context) => UserProfileScreen(),
              '/user_settings': (context) => UserSettingsScreen(),
              '/product_list': (context) => ProductListScreen(),
              '/product_form': (context) => ProductFormScreen(),
              '/product_edit': (context) {
                final product = ModalRoute.of(context)!.settings.arguments as dynamic;
                return ProductEditScreen(product: product);
              },
              '/admin': (context) => AdminScreen(),
              '/tienda_list': (context) => TiendaListScreen(),
              '/tienda_form': (context) => TiendaFormScreen(), // Nueva pantalla de formulario de tiendas
              '/tienda_edit': (context) {
                final tienda = ModalRoute.of(context)!.settings.arguments as dynamic;
                return TiendaEditScreen(tienda: tienda); // Nueva pantalla de edición de tiendas
              },
            },
          );
        },
      ),
    );
  }
}

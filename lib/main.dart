import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart'; // Manteniendo tus rutas actuales
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart'; // Pantalla de configuración
import 'screens/user_profile_screen.dart';
import 'screens/user_settings_screen.dart'; // Configuración del usuario
import 'firebase_options.dart'; // Asegúrate de tener bien configurado Firebase
import 'package:celiapp/widgets/apps_colors.dart'; // Importa tu clase de colores
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
      create: (_) => ThemeNotifier(), // Este es el proveedor de tema
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
              '/settings': (context) =>
                  SettingsScreen(), // Pantalla de configuración
              '/profile': (context) => UserProfileScreen(),
              '/user_settings': (context) => UserSettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

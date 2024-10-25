import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/apps_colors.dart';
import 'package:celiapp/screens/theme_notifier.dart'; // Asegúrate de tener tu archivo de colores

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Cambia `ThemeModel` por `ThemeNotifier`
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Modo oscuro'),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value); // Cambiar el tema
                },
              ),
            ),
            // Otras configuraciones si las tienes
          ],
        ),
      ),
    );
  }
}

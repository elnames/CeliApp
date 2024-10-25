import 'package:flutter/material.dart';
import '../widgets/apps_colors.dart';
import 'product_list_screen.dart';
import 'tienda_list_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verificar si el tema es oscuro o claro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Panel de Administración',
          style: TextStyle(color: AppColors.text100),
        ),
        backgroundColor:
            isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
        iconTheme: IconThemeData(color: AppColors.text100),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Número de columnas
          crossAxisSpacing: 16, // Espacio horizontal entre tarjetas
          mainAxisSpacing: 16, // Espacio vertical entre tarjetas
          children: [
            _buildAdminOptionCard(
              context,
              icon: Icons.shopping_bag,
              text: 'Gestionar Productos',
              color: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListScreen()),
                );
              },
            ),
            _buildAdminOptionCard(
              context,
              icon: Icons.store,
              text: 'Gestionar Tiendas',
              color: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TiendaListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOptionCard(BuildContext context,
      {required IconData icon,
      required String text,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: AppColors.text100,
            ),
            SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

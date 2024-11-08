import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'product_management_screen.dart';
import 'store_management_screen.dart';
import 'user_management_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg100 : AppColors.lightBg100,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg200 : AppColors.lightBg200,
        elevation: 0,
        title: Text(
          'Panel de Administración',
          style: TextStyle(
            color: isDark ? AppColors.darkText100 : AppColors.lightText100,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppColors.darkText100 : AppColors.lightText100),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText100 : AppColors.lightText100,
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildAdminCard(
                  context,
                  'Productos',
                  Icons.inventory,
                  Colors.blue[400]!,
                  'Gestionar catálogo de productos',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductManagementScreen()),
                  ),
                ),
                _buildAdminCard(
                  context,
                  'Tiendas',
                  Icons.store,
                  Colors.orange[400]!,
                  'Administrar tiendas',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StoreManagementScreen()),
                  ),
                ),
                _buildAdminCard(
                  context,
                  'Usuarios',
                  Icons.people,
                  Colors.purple[400]!,
                  'Gestionar usuarios',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserManagementScreen()),
                  ),
                ),
                // Puedes agregar más cards aquí según necesites
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

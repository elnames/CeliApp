import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/main_scaffold.dart';
import '../services/favorites_service.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../constants/app_colors.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 4,
      onAuthenticationRequired: () {},
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildFavorites(),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: _buildSettingsButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.settings, color: Colors.grey[800]),
      ),
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit_profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: Colors.grey[800], size: 20),
              SizedBox(width: 12),
              Text('Editar perfil'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'change_password',
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.grey[800], size: 20),
              SizedBox(width: 12),
              Text('Cambiar contraseña'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'theme',
          child: Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, _) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Row(
                children: [
                  Icon(
                    Icons.brightness_6,
                    color: isDark ? AppColors.darkText100 : AppColors.lightText100,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Tema Oscuro',
                    style: TextStyle(
                      color: isDark ? AppColors.darkText100 : AppColors.lightText100,
                    ),
                  ),
                  Spacer(),
                  Switch(
                    value: isDark,
                    onChanged: (_) => themeNotifier.toggleTheme(),
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withOpacity(0.5),
                  ),
                ],
              );
            },
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit_profile':
            _editNameDialog();
            break;
          case 'change_password':
            _editPasswordDialog();
            break;
          case 'logout':
            _handleLogout();
            break;
        }
      },
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final displayName = userData['displayName'] ?? 'Usuario';
          
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 40,
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildFavorites() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: user != null ? FavoritesService.getUserFavorites(user!.uid) : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final favorites = snapshot.data ?? [];

        return Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg200 : AppColors.lightBg200,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppColors.error,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Mis Favoritos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText100 : AppColors.lightText100,
                      ),
                    ),
                  ],
                ),
              ),
              if (favorites.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No tienes productos favoritos',
                    style: TextStyle(
                      color: isDark ? AppColors.darkText200 : AppColors.lightText200,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = favorites[index];
                    return _buildFavoriteItem(product);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        product['nombre'] ?? '',
        style: TextStyle(
          color: isDark ? AppColors.darkText100 : AppColors.lightText100,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        product['categoria'] ?? '',
        style: TextStyle(
          color: isDark ? AppColors.darkText200 : AppColors.lightText200,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.favorite, color: AppColors.error),
        onPressed: () => _toggleFavorite(product['id_producto'].toString()),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _editPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Contraseña'),
        content: Text('¿Deseas cambiar tu contraseña? Te enviaremos un correo electrónico para restablecerla.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: user?.email ?? '',
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Se ha enviado un correo para restablecer tu contraseña')),
              );
            },
            child: Text('Enviar Correo'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(String productId) async {
    try {
      bool success = await FavoritesService.removeFromFavorites(user!.uid, productId);
      
      if (success) {
        // Recargar la lista de favoritos
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eliminado de favoritos'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.grey[800],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar favoritos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editNameDialog() {
    final TextEditingController nameController = TextEditingController(text: user?.displayName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Nombre'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nuevo nombre',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (user != null) {
                  await user!.updateDisplayName(nameController.text);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({'displayName': nameController.text});
                      
                  Navigator.pop(context);
                  setState(() {});
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nombre actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar el nombre'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

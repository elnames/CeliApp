import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileCard(context), // Card con la información del usuario
              SizedBox(height: 20),
              _buildFavoritesSection(context), // Sección de productos favoritos
              SizedBox(height: 20),
              _buildFavoriteStoresSection(context), // Sección de tiendas favoritas
            ],
          ),
        ),
      ),
    );
  }

  // Card de información del perfil
  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Image.network(
                user?.photoURL ?? 'https://via.placeholder.com/150',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Nombre no disponible',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  user?.email ?? 'Correo no disponible',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                Text('Productos favoritos: 64'),
                Text('Tiendas favoritas: 32'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Sección de productos favoritos
  Widget _buildFavoritesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos favoritos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildProductCard('Pan sin gluten', 'assets/images/logo.png'),
            _buildProductCard('Pastas sin gluten', 'assets/images/logo.png'),
          ],
        ),
      ],
    );
  }

  // Sección de tiendas favoritas
  Widget _buildFavoriteStoresSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiendas favoritas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStoreCard('Tienda 1'),
            _buildStoreCard('Tienda 2'),
          ],
        ),
      ],
    );
  }

  // Tarjeta de productos
  Widget _buildProductCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Navegar a detalles del producto si es necesario
      },
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(imagePath, height: 100),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.favorite, color: Colors.red),
          ],
        ),
      ),
    );
  }

  // Tarjeta de tiendas favoritas
  Widget _buildStoreCard(String storeName) {
    return GestureDetector(
      onTap: () {
        // Navegar a detalles de la tienda si es necesario
      },
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            storeName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

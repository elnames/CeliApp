// recommended_products_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecommendedProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    print('RecommendedProductsScreen: currentUser = \$user');
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos Recomendados'),
      ),
      body: ListView.builder(
        itemCount: 10, // Este número se actualizará según los productos obtenidos desde la fuente
        itemBuilder: (context, index) {
          print('RecommendedProductsScreen: Building product item \$index');
          return ListTile(
            leading: Image.network('https://via.placeholder.com/150'), // Enlazar con la imagen del producto
            title: Text('Producto \$index'), // Nombre del producto
            subtitle: Text('Descripción del producto'),
            onTap: () {
              if (user != null) {
                // Acción al tocar el producto para usuarios autenticados
                print('RecommendedProductsScreen: User is authenticated, navigating to product details');
                Navigator.pushNamed(context, '/product_details', arguments: index); // Ir a detalles del producto
              } else {
                // Acción al tocar el producto para usuarios no autenticados
                print('RecommendedProductsScreen: User not authenticated, showing login prompt');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Debes iniciar sesión para acceder a los detalles del producto.')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/product_image.png'), // Imagen del producto.
            SizedBox(height: 16),
            Text('Nombre del Producto', style: TextStyle(fontSize: 24)),
            Text('Descripción del producto y detalles relevantes.'),
          ],
        ),
      ),
    );
  }
}

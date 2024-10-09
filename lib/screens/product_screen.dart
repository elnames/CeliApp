import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/product_image.png'), // Imagen del producto.
            const SizedBox(height: 16),
            const Text('Nombre del Producto', style: TextStyle(fontSize: 24)),
            const Text('Descripción del producto y detalles relevantes.'),
          ],
        ),
      ),
    );
  }
}

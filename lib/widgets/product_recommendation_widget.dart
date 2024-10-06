// product_recommendation_widget.dart
import 'package:flutter/material.dart';

class ProductRecommendationWidget extends StatelessWidget {
  final bool isLoggedIn;
  ProductRecommendationWidget({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Alimentos Recomendados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4, // Replace with dynamic count
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (!isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Debes iniciar sesión para acceder.')),
                    );
                  } else {
                    // Navigate to product details
                  }
                },
                child: Card(
                  child: Container(
                    width: 150,
                    child: Column(
                      children: [
                        Image.network('https://via.placeholder.com/150'), // Replace with actual product image
                        Text('Producto $index'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
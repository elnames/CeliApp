// product_recommendation_widget.dart
import 'package:flutter/material.dart';

class ProductRecommendationWidget extends StatelessWidget {
  final bool isLoggedIn;
  const ProductRecommendationWidget({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Alimentos Recomendados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4, // Replace with dynamic count
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (!isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Debes iniciar sesión para acceder.')),
                    );
                  } else {
                    // Navigate to product details
                  }
                },
                child: Card(
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      children: [
                        Image.network(
                            'https://via.placeholder.com/150'), // Replace with actual product image
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

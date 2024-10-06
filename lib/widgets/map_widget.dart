// map_widget.dart
import 'package:flutter/material.dart';

class MapWidget extends StatelessWidget {
  final bool isLoggedIn;
  MapWidget({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Debes iniciar sesión para acceder.')),
          );
        } else {
          // Navigate to locales cercanos screen
        }
      },
      child: Container(
        height: 200,
        color: Colors.blueAccent,
        child: Center(
          child: Text('Ver Locales Cercanos', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}

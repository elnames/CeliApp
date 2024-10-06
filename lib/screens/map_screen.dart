import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Locales Cercanos')),
      body: Center(child: Text('Aquí se mostrará el mapa con los locales cercanos')),
    );
  }
}

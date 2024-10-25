import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  final LatLng _initialPosition = const LatLng(
      -33.4489, -70.6693); // Coordenadas de ejemplo (Santiago, Chile)

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Completo'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('initialPosition'),
            position: _initialPosition,
            infoWindow: const InfoWindow(
              title: 'Ubicación de Ejemplo',
              snippet: 'Este es un punto de interés',
            ),
          ),
        },
      ),
    );
  }
}

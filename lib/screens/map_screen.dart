import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/main_scaffold.dart';
import '../constants/app_colors.dart';

class MapScreen extends StatefulWidget {
  final List<dynamic> stores;
  
  const MapScreen({
    super.key,
    required this.stores,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Map<String, dynamic>? selectedStore;
  Position? userLocation;
  List<Map<String, dynamic>> sortedStores = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    await _getCurrentLocation();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
        
        setState(() {
          userLocation = position;
        });

        _sortStoresByDistance();
        _createMarkers();
        
        if (mapController != null) {
          await mapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude),
              14.0,
            ),
          );
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _sortStoresByDistance() {
    if (userLocation == null) return;

    sortedStores = widget.stores.map((store) {
      try {
        double distance = 0.0;
        if (store['latitud'] != null && store['longitud'] != null) {
          distance = Geolocator.distanceBetween(
            userLocation!.latitude,
            userLocation!.longitude,
            double.tryParse(store['latitud'].toString()) ?? 0.0,
            double.tryParse(store['longitud'].toString()) ?? 0.0,
          );
        }
        
        // Crear un nuevo Map con los datos necesarios
        return <String, dynamic>{
          'id_tienda': store['id_tienda'] ?? '',
          'nombre': store['nombre'] ?? '',
          'direccion': store['direccion'] ?? '',
          'latitud': store['latitud'] ?? '0.0',
          'longitud': store['longitud'] ?? '0.0',
          'distance': distance,
          'tipo': store['tipo'] ?? '',
          'telefono': store['telefono'] ?? '',
          'horario': store['horario'] ?? '',
          // Agrega aquí cualquier otro campo que necesites
        };
      } catch (e) {
        print('Error calculando distancia para tienda: ${store['nombre']} - $e');
        return <String, dynamic>{
          'id_tienda': store['id_tienda'] ?? '',
          'nombre': store['nombre'] ?? '',
          'direccion': store['direccion'] ?? '',
          'latitud': store['latitud'] ?? '0.0',
          'longitud': store['longitud'] ?? '0.0',
          'distance': double.infinity,
          'tipo': store['tipo'] ?? '',
          'telefono': store['telefono'] ?? '',
          'horario': store['horario'] ?? '',
          // Agrega aquí cualquier otro campo que necesites
        };
      }
    }).toList();

    sortedStores.sort((a, b) => 
      (a['distance'] as double).compareTo(b['distance'] as double)
    );
    
    if (sortedStores.isNotEmpty && selectedStore == null) {
      setState(() {
        selectedStore = sortedStores.first;
      });
    }
  }

  void _createMarkers() {
    markers.clear();
    
    // Agregar marcador del usuario
    if (userLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(userLocation!.latitude, userLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: 'Tu ubicación'),
        ),
      );
    }

    // Agregar marcadores de tiendas
    for (var store in sortedStores) {
      markers.add(
        Marker(
          markerId: MarkerId(store['id_tienda'].toString()),
          position: LatLng(
            double.parse(store['latitud'].toString()),
            double.parse(store['longitud'].toString()),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _selectStore(store),
        ),
      );
    }
  }

  Future<void> _openMapsNavigation(Map<String, dynamic> store) async {
    if (userLocation == null) return;

    final lat = double.parse(store['latitud'].toString());
    final lng = double.parse(store['longitud'].toString());
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${userLocation!.latitude},${userLocation!.longitude}&destination=$lat,$lng';
    
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _selectStore(Map<String, dynamic> store) async {
    setState(() {
      selectedStore = store;
    });
    
    try {
      final lat = double.parse(store['latitud'].toString());
      final lng = double.parse(store['longitud'].toString());
      
      await mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(lat, lng),
          15.0,
        ),
      );
    } catch (e) {
      print('Error al centrar el mapa: $e');
    }
  }

  // Información de la tienda más cercana
  Widget _buildNearestStoreInfo() {
    if (selectedStore == null) return SizedBox();

    final distance = (selectedStore!['distance'] as double) / 1000;
    
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedStore!['nombre'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      selectedStore!['direccion'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _openMapsNavigation(selectedStore!),
                icon: Icon(Icons.directions, color: AppColors.primary),
                label: Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          if (selectedStore!['horario'] != null) ...[
            SizedBox(height: 8),
            Text(
              'Horario: ${selectedStore!['horario']}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 1,
      onAuthenticationRequired: () {},
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : Column(
          children: [
            // Buscador
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '¿Qué estás buscando hoy?',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.tune, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            // Mapa
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      if (userLocation != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(userLocation!.latitude, userLocation!.longitude),
                            14.0,
                          ),
                        );
                      }
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(-33.4489, -70.6693),
                      zoom: 12,
                    ),
                    markers: markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: _getCurrentLocation,
                      child: Icon(Icons.my_location, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Información de la tienda más cercana
            _buildNearestStoreInfo(),

            // Categorías
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCategoryButton(Icons.store, 'Tiendas'),
                  _buildCategoryButton(Icons.shopping_cart, 'Supermercados'),
                  _buildCategoryButton(Icons.restaurant, 'Restaurantes'),
                  _buildCategoryButton(Icons.coffee, 'Café'),
                  _buildCategoryButton(Icons.more_horiz, 'Más'),
                ],
              ),
            ),

            // Lista de tiendas
            Expanded(
              child: sortedStores.isEmpty
                ? Center(
                    child: Text('No se encontraron tiendas cercanas'),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: sortedStores.length,
                    itemBuilder: (context, index) {
                      final store = sortedStores[index];
                      final isSelected = selectedStore?['id_tienda'] == store['id_tienda'];
                      final distance = (store['distance'] as double) / 1000; // Convertir a km

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[50] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.store,
                            color: isSelected ? Colors.blue : Colors.grey[600],
                          ),
                          title: Text(
                            store['nombre'] ?? '',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${store['direccion'] ?? ''} • ${distance.toStringAsFixed(1)} km',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.directions),
                            color: Colors.blue,
                            onPressed: () => _openMapsNavigation(store),
                          ),
                          onTap: () => _selectStore(store),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
    );
  }

  Widget _buildCategoryButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

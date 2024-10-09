import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('CeliApp'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.account_circle), // Ícono de usuario
            onSelected: (item) => _onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text('Mi perfil')),
              PopupMenuItem<int>(value: 1, child: Text('Configuración de la cuenta')),
              PopupMenuItem<int>(value: 2, child: Text('Cerrar sesión')), // Opción para cerrar sesión
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú de la app',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración de la app'),
              onTap: () {
                Navigator.pushNamed(context, '/app_settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('FAQ'),
              onTap: () {
                Navigator.pushNamed(context, '/faq');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user != null
                    ? '¡Hola ${user!.displayName ?? 'Usuario'}!, ¿Qué estás buscando hoy?'
                    : '¡Hola Invitado!, ¿Qué estás buscando hoy?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Busca tu local o comida favorita',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Comida recomendada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              _buildRecommendedProducts(), // Sección de productos recomendados
              SizedBox(height: 20),
              Text(
                'Locales cercanos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              _buildMapSection(), // Sección del mapa
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedProducts() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildProductCard('Pan sin gluten', 'assets/images/logo.png'),
        _buildProductCard('Pastas sin gluten', 'assets/images/logo.png'),
      ],
    );
  }

  Widget _buildProductCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          // Los usuarios autenticados pueden acceder a más detalles
          Navigator.pushNamed(context, '/product_details', arguments: title);
        } else {
          // Mostrar mensaje para usuarios invitados
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inicia sesión para ver más detalles del producto.')),
          );
        }
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
            Icon(Icons.location_on, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          // Usuarios autenticados pueden acceder a la pantalla completa del mapa
          Navigator.pushNamed(context, '/map');
        } else {
          // Mostrar mensaje para usuarios invitados
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inicia sesión para acceder al mapa completo.')),
          );
        }
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(-33.4489, -70.6693),
              zoom: 12.0,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            scrollGesturesEnabled: false, // Deshabilitar para invitados
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            markers: {
              Marker(
                markerId: MarkerId('marker_1'),
                position: LatLng(-33.4489, -70.6693),
                infoWindow: InfoWindow(title: 'Local 1'),
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
        ),
      ),
    );
  }

  // Controlador de selección de menú desplegable
  void _onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushNamed(context, '/user_profile');
        break;
      case 1:
        Navigator.pushNamed(context, '/user_settings');
        break;
      case 2:
        _logout(context);
        break;
    }
  }

  // Función para cerrar sesión y redirigir al home como invitado
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Cerrar sesión
      setState(() {
        user = null; // El usuario ahora es invitado
      });
      Navigator.pushReplacementNamed(context, '/home'); // Redirigir al home como invitado
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/apps_colors.dart'; // Asegúrate de que esta ruta esté correcta

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user; // Variable para almacenar el usuario autenticado, si existe
  GoogleMapController? _mapController; // Controlador del mapa de Google Maps

  @override
  void initState() {
    super.initState();
    // Al iniciar el widget, obtenemos el usuario autenticado desde Firebase
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si el tema es oscuro o claro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'CeliApp',
          style: TextStyle(
              color: AppColors.text100), // Aplicar color de texto según el tema
        ),
        backgroundColor: isDarkMode
            ? AppColors.darkPrimary100 // Color del AppBar en modo oscuro
            : AppColors.lightPrimary100, // Color del AppBar en modo claro
        iconTheme: IconThemeData(color: AppColors.text100), // Íconos del AppBar
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () {
                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context)
                      .context
                      .findRenderObject() as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset(0, button.size.height),
                          ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero),
                          ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );

                  showMenu(
                    context: context,
                    position: position,
                    items: user != null
                        ? [
                            PopupMenuItem(
                              value: 'perfil',
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text('Mi perfil'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'config',
                              child: ListTile(
                                leading: Icon(Icons.settings),
                                title: Text('Configuración de la cuenta'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(Icons.logout),
                                title: Text('Cerrar sesión'),
                              ),
                            ),
                          ]
                        : [
                            PopupMenuItem(
                              value: 'login',
                              child: ListTile(
                                leading: Icon(Icons.login),
                                title: Text('Iniciar sesión'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'register',
                              child: ListTile(
                                leading: Icon(Icons.app_registration),
                                title: Text('Registrarse'),
                              ),
                            ),
                          ],
                  ).then((value) {
                    if (value == 'logout') {
                      FirebaseAuth.instance.signOut().then((_) {
                        Navigator.pushReplacementNamed(context, '/home');
                      });
                    } else if (value == 'perfil') {
                      Navigator.pushNamed(context, '/profile');
                    } else if (value == 'config') {
                      Navigator.pushNamed(context, '/user_settings');
                    } else if (value == 'login') {
                      Navigator.pushNamed(context, '/login');
                    } else if (value == 'register') {
                      Navigator.pushNamed(context, '/register');
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkPrimary100
                    : AppColors.lightPrimary100, // Uso de la paleta de colores
              ),
              child: Text(
                'CeliApp Menu',
                style: TextStyle(color: AppColors.text100, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración de la app'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('FAQ'),
              onTap: () {
                Navigator.pop(context);
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,
                      color: isDarkMode ? Colors.white70 : Colors.black54),
                  hintText: 'Busca tu local o comida favorita',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Comida recomendada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              _buildRecommendedProducts(
                  isDarkMode), // Sección de productos recomendados
              SizedBox(height: 20),
              Text(
                'Tiendas recomendadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              _buildRecommendedStores(
                  isDarkMode), // Sección de tiendas recomendadas
              SizedBox(height: 20),
              Text(
                'Locales cercanos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              _buildMapSection(isDarkMode), // Sección del mapa
            ],
          ),
        ),
      ),
    );
  }

  // Función para construir la sección de productos recomendados
  Widget _buildRecommendedProducts(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildProductCard(
            'Pan sin gluten', 'assets/images/pan.png', isDarkMode),
        _buildProductCard(
            'Pastas sin gluten', 'assets/images/pastas.png', isDarkMode),
      ],
    );
  }

  // Función para construir la sección de tiendas recomendadas
  Widget _buildRecommendedStores(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStoreCard('Tienda 1', 'assets/images/jumbo.png', isDarkMode),
        _buildStoreCard('Tienda 2', 'assets/images/adios.png', isDarkMode),
      ],
    );
  }

  // Función para construir las tarjetas de productos individuales
  Widget _buildProductCard(String title, String imagePath, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          Navigator.pushNamed(context, '/product_details', arguments: title);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Inicia sesión para ver más detalles del producto.')),
          );
        }
      },
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            Icon(Icons.location_on, color: Colors.green),
          ],
        ),
      ),
    );
  }

  // Función para construir las tarjetas de tiendas recomendadas
  Widget _buildStoreCard(String title, String imagePath, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          Navigator.pushNamed(context, '/store_details', arguments: title);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Inicia sesión para ver más detalles de la tienda.')),
          );
        }
      },
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            Icon(Icons.store, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  // Función para construir la sección del mapa de Google Maps
  Widget _buildMapSection(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          Navigator.pushNamed(context, '/map');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Inicia sesión para acceder al mapa completo.')),
          );
        }
      },
      child: Container(
        height: 200,
        child: GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(-33.4489, -70.6693),
            zoom: 12,
          ),
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          scrollGesturesEnabled: user != null,
          zoomGesturesEnabled: user != null,
          rotateGesturesEnabled: user != null,
          tiltGesturesEnabled: user != null,
          onTap: (LatLng position) {
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Inicia sesión para interactuar con el mapa.'),
                ),
              );
            } else {
              Navigator.pushNamed(context, '/map');
            }
          },
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

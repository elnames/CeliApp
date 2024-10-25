import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para Firestore
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/apps_colors.dart'; // Asegúrate de que esta ruta esté correcta
import 'admin_screen.dart'; // Pantalla de admin para gestión de CRUDs

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user; // Variable para almacenar el usuario autenticado, si existe
  GoogleMapController? _mapController; // Controlador del mapa de Google Maps
  bool isAdmin = false; // Variable para determinar si el usuario es admin

  @override
  void initState() {
    super.initState();
    // Al iniciar el widget, obtenemos el usuario autenticado desde Firebase
    user = FirebaseAuth.instance.currentUser;

    // Verificamos si el usuario tiene el rol de administrador
    _checkIfAdmin();
  }

  // Función para verificar si el usuario es admin
  Future<void> _checkIfAdmin() async {
    if (user != null) {
      // Obtenemos el documento del usuario desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          // Asignamos 'isAdmin' basado en el campo 'role' en Firestore
          isAdmin = userDoc['role'] == 'admin';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si el tema es oscuro o claro
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDarkMode),
      drawer: _buildDrawer(isDarkMode),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingText(isDarkMode),
              SizedBox(height: 10),
              _buildSearchBar(isDarkMode),
              SizedBox(height: 20),
              _buildSectionTitle('Comida recomendada', isDarkMode),
              SizedBox(height: 10),
              _buildRecommendedProducts(isDarkMode),
              SizedBox(height: 20),
              _buildSectionTitle('Tiendas recomendadas', isDarkMode),
              SizedBox(height: 10),
              _buildRecommendedStores(isDarkMode),
              SizedBox(height: 20),
              _buildSectionTitle('Locales cercanos', isDarkMode),
              SizedBox(height: 10),
              _buildMapSection(isDarkMode), // Actualizado para el mapa
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDarkMode) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'CeliApp',
        style: TextStyle(color: AppColors.text100),
      ),
      backgroundColor:
          isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
      iconTheme: IconThemeData(color: AppColors.text100),
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
              onPressed: () => _showMenu(context),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(bool isDarkMode) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkPrimary100
                  : AppColors.lightPrimary100,
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
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

     // Mostrar el menú, incluyendo la opción "Admin" solo si el usuario es admin
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
              if (isAdmin)
                PopupMenuItem(
                  value: 'admin',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings),
                    title: Text('Admin'), // Opción solo para administradores
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
      } else if (value == 'admin') {
        // Navegar a la pantalla Admin si el usuario es admin
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
        );
      }
    });
  }

  Widget _buildGreetingText(bool isDarkMode) {
    return Text(
      user != null
          ? '¡Hola ${user!.displayName ?? 'Usuario'}!, ¿Qué estás buscando hoy?'
          : '¡Hola Invitado!, ¿Qué estás buscando hoy?',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return TextField(
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
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white70 : Colors.black87,
      ),
    );
  }

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

  Widget _buildProductCard(String title, String imagePath, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          Navigator.pushNamed(context, '/product_details', arguments: title);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Inicia sesión para ver más detalles del producto.'),
            ),
          );
        }
      },
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.darkBg300
              : AppColors.lightBg300, // Ajuste de colores
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

  Widget _buildRecommendedStores(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStoreCard('Tienda 1', 'assets/images/jumbo.png', isDarkMode),
        _buildStoreCard('Tienda 2', 'assets/images/adios.png', isDarkMode),
      ],
    );
  }

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
          color: isDarkMode
              ? AppColors.darkBg300
              : AppColors.lightBg300, // Ajuste de colores
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

  Widget _buildMapSection(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          // Si el usuario está autenticado, navegar a la pantalla del mapa
          Navigator.pushNamed(context, '/map');
        } else {
          // Si el usuario no está autenticado, mostrar un SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inicia sesión para acceder al mapa completo.'),
            ),
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
          scrollGesturesEnabled: true,  // Siempre permitir gestos en el mapa
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/apps_colors.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  GoogleMapController? _mapController;
  bool isAdmin = false;

  List<dynamic> _products = [];
  List<dynamic> _stores = [];
  bool _isLoadingProducts = true;
  bool _isLoadingStores = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _checkIfAdmin();
    _fetchProducts();
    _fetchStores();
  }

  Future<void> _checkIfAdmin() async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          isAdmin = userDoc.data()?['role'] == 'admin';
        });
      }
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos'));

      if (response.statusCode == 200) {
        setState(() {
          _products = json.decode(response.body).take(10).toList();
          _isLoadingProducts = false;
        });
      } else {
        setState(() {
          _isLoadingProducts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los productos: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los productos: $e')),
      );
    }
  }

  Future<void> _fetchStores() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/tiendas'));

      if (response.statusCode == 200) {
        setState(() {
          _stores = json.decode(response.body).take(10).toList();
          _isLoadingStores = false;
        });
      } else {
        setState(() {
          _isLoadingStores = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las tiendas: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingStores = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las tiendas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildSectionTitle('Comida recomendada', isDarkMode, '/product_catalog'),
              SizedBox(height: 10),
              _buildRecommendedProducts(isDarkMode),
              SizedBox(height: 20),
              _buildSectionTitle('Tiendas recomendadas', isDarkMode, '/store_catalog'),
              SizedBox(height: 10),
              _buildRecommendedStores(isDarkMode),
              SizedBox(height: 20),
              _buildSectionTitle('Locales cercanos', isDarkMode, null),
              SizedBox(height: 10),
              _buildMapSection(isDarkMode),
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
      backgroundColor: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
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
              color: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
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
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
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
              if (isAdmin)
                PopupMenuItem(
                  value: 'admin',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings),
                    title: Text('Admin'),
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
        prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
        hintText: 'Busca tu local o comida favorita',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode, String? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              decoration: route != null ? TextDecoration.underline : null,
            ),
          ),
          if (route != null)
            IconButton(
              icon: Icon(Icons.arrow_forward, color: isDarkMode ? Colors.white70 : Colors.black87),
              onPressed: () {
                Navigator.pushNamed(context, route);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProducts(bool isDarkMode) {
    return _isLoadingProducts
        ? Center(child: CircularProgressIndicator())
        : _products.isEmpty
            ? Center(child: Text("No hay productos disponibles"))
            : SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    var product = _products[index];
                    return _buildProductCard(product, isDarkMode);
                  },
                ),
              );
  }

  Widget _buildProductCard(dynamic product, bool isDarkMode) {
    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xFFF4CE92),  // Color claro que mencionaste anteriormente
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              product['url_imagen'] ?? 'https://via.placeholder.com/150',
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product['nombre'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedStores(bool isDarkMode) {
    return _isLoadingStores
        ? Center(child: CircularProgressIndicator())
        : _stores.isEmpty
            ? Center(child: Text("No hay tiendas disponibles"))
            : SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stores.length,
                  itemBuilder: (context, index) {
                    var store = _stores[index];
                    return _buildStoreCard(store, isDarkMode);
                  },
                ),
              );
  }

  Widget _buildStoreCard(dynamic store, bool isDarkMode) {
    return Container(
      width: 150,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xFFF4CE92), // Color claro que mencionaste anteriormente
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              store['image'] ?? 'https://via.placeholder.com/150',
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              store['nombre'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          Navigator.pushNamed(context, '/map');
        } else {
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
          scrollGesturesEnabled: true,
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

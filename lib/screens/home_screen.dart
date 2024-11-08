import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/main_scaffold.dart';
import '../services/favorites_service.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/admin_screen.dart';
import '../widgets/product_card.dart';
import '../screens/catalog_screen.dart';
import '../screens/map_screen.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  User? user;
  bool isAdmin = false;
  bool isSubscribed = false;
  List<dynamic> _products = [];
  List<dynamic> _allProducts = [];
  List<dynamic> _stores = [];
  List<String> _categories = ["Todos"];
  String _selectedCategory = "Todos";
  bool _isLoadingProducts = true;
  bool _isLoadingStores = true;
  List<dynamic> _searchResults = [];
  bool _showSearchResults = false;
  bool _isFavorite = false;
  late TabController _authTabController;
  late GoogleMapController mapController;
  late BitmapDescriptor storeIcon;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer.asUint8List();
  }

  Future<void> loadCustomIcon() async {
    final bytes = await getBytesFromAsset('assets/images/store_icon.png', 200);
    setState(() {
      storeIcon = BitmapDescriptor.fromBytes(bytes);
    });
  }

  @override
  void initState() {
    super.initState();
    _authTabController = TabController(length: 2, vsync: this);
    user = _auth.currentUser;
    _checkAdminStatus();
    _loadInitialData();
    loadCustomIcon();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchProducts(),
      _fetchStores(),
      _fetchCategories(),
    ]);
  }

  @override
  void dispose() {
    _authTabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });
    
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data;
          _allProducts = data;
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
      print('Error al cargar productos: $e');
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
          _stores = json.decode(response.body);
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

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos/categorias'));
      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> data = json.decode(response.body);
          _categories = ['Todas', ...List<String>.from(data)];
          _selectedCategory = 'Todas';
        });
      }
    } catch (e) {
      print('Error al cargar categorías: $e');
      setState(() {
        _categories = ['Todas'];
        _selectedCategory = 'Todas';
      });
    }
  }

  void _filterProducts(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Todas') {
        final List<dynamic> shuffledProducts = List.from(_allProducts)..shuffle();
        _products = shuffledProducts.take(10).toList();
      } else {
        _products = _allProducts.where((product) => 
          product['categoria'].toString() == category
        ).toList();
      }
    });
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
        _showSearchResults = false;
        _showRandomProducts();
        return;
      }

      _showSearchResults = true;
      _searchResults = _allProducts.where((product) {
        final nombre = product['nombre'].toString().toLowerCase();
        final categoria = product['categoria'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return nombre.contains(searchLower) || 
               categoria.contains(searchLower);
      }).toList();
      
      _products = _searchResults;
    });
  }

  void _hideSearchResults() {
    setState(() {
      _showSearchResults = false;
      _searchResults.clear();
    });
  }

  Future<void> _toggleFavorite(String productId) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión para guardar favoritos')),
      );
      return;
    }

    bool success;
    if (_isFavorite) {
      success = await FavoritesService.removeFromFavorites(user!.uid, productId);
    } else {
      success = await FavoritesService.addToFavorites(user!.uid, productId);
    }

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Agregado a favoritos' : 'Eliminado de favoritos'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  void _handleAuthenticationRequired() {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _nameController = TextEditingController();
    final _loginFormKey = GlobalKey<FormState>();
    final _registerFormKey = GlobalKey<FormState>();
    bool _isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: DefaultTabController(
          length: 2,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ingresa tus datos para continuar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 20),
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.secondary.withOpacity(0.5),
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  tabs: [
                    Tab(text: 'Iniciar Sesión'),
                    Tab(text: 'Registrarse'),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: _buildLoginForm(
                          _emailController,
                          _passwordController,
                          _loginFormKey,
                          _isPasswordVisible,
                          setState,
                        ),
                      ),
                      SingleChildScrollView(
                        child: _buildRegisterForm(
                          _emailController,
                          _passwordController,
                          _nameController,
                          _registerFormKey,
                          _isPasswordVisible,
                          setState,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() => _loadInitialData());
  }

  void _handleRestrictedAccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acceso Restringido'),
        content: Text('Para acceder a esta función necesitas iniciar sesión'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth');
            },
            child: Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAdminStatus() async {
    try {
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            isAdmin = userData['role'] == 'admin';
          });
        } else {
          setState(() {
            isAdmin = false;
          });
        }
      } else {
        setState(() {
          isAdmin = false;
        });
      }
    } catch (e) {
      print('Error al verificar estado de admin: $e');
      setState(() {
        isAdmin = false;
      });
    }
  }

  void _showRandomProducts() {
    if (_allProducts.isNotEmpty) {
      setState(() {
        final List<dynamic> shuffledProducts = List.from(_allProducts)..shuffle();
        _products = shuffledProducts.take(10).toList();
      });
    }
  }

  void _checkAuthAndNavigate(Widget destination) {
    if (_auth.currentUser == null) {
      _handleAuthenticationRequired();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = themeNotifier.isDarkMode;
        return MainScaffold(
          currentIndex: 0,
          showFloatingButton: false,
          showAppBar: false,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    _buildSearchBar(),
                    SizedBox(height: 20),
                    _buildSectionTitle("Productos", () {
                      _checkAuthAndNavigate(CatalogScreen());
                    }),
                    _buildCategorySelector(),
                    SizedBox(height: 16),
                    _buildProductList(),
                    SizedBox(height: 20),
                    _buildSectionTitle("Locales Cercanos", () {
                      _checkAuthAndNavigate(CatalogScreen());
                    }),
                    _buildStoreList(),
                    SizedBox(height: 20),
                    _buildMapSection(),
                  ],
                ),
              ),
              if (_showSearchResults)
                Positioned(
                  top: 155,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? AppColors.darkBg200 : Colors.white,
                    child: _buildSearchResults(),
                  ),
                ),
            ],
          ),
          onAuthenticationRequired: _handleAuthenticationRequired,
        );
      }
    );
  }

  Widget _buildSearchResults() {
    return _showSearchResults
        ? Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return ListTile(
                  leading: item['id_producto'] != null
                      ? Image.network(
                          'https://storage.googleapis.com/celiapp-bucket/${item['id_producto']}.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.store),
                  title: Text(item['nombre']),
                  subtitle: Text(item['id_producto'] != null ? 'Producto' : 'Tienda'),
                  onTap: () {
                    if (item['id_producto'] != null) {
                      Navigator.pushNamed(context, '/product_detail', arguments: item);
                    } else {
                      Navigator.pushNamed(context, '/store_detail', arguments: item);
                    }
                  },
                );
              },
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildGreeting() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '¡Hola${user != null ? ', ${user!.displayName ?? ""}' : ''}!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isAdmin)
                      IconButton(
                        icon: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.orange,
                          size: 24,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminScreen()),
                        ),
                      ),
                  ],
                ),
                Text(
                  '¿Qué estás buscando hoy?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: _searchProducts,
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
            ),
            suffixIcon: _showSearchResults 
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _searchResults.clear();
                      _showSearchResults = false;
                    });
                  },
                )
              : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback? onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {
            _checkAuthAndNavigate(CatalogScreen());
          },
          child: Text(
            'Ver todos',
            style: TextStyle(
              color: Colors.grey[800]
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : Colors.grey[600],
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  _filterProducts(category);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    return _isLoadingProducts
        ? Center(child: CircularProgressIndicator())
        : _products.isEmpty
            ? Center(child: Text("No hay productos disponibles"))
            : Container(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: ProductCard(
                        product: _products[index],
                        onFavoriteChanged: () {},
                      ),
                    );
                  },
                ),
              );
  }

  Widget _buildStoreList() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stores.length,
        itemBuilder: (context, index) {
          final store = _stores[index];
          return GestureDetector(
            onTap: () {
              if (user != null) {
                _centerMapOnStore(store);
              } else {
                _handleRestrictedAccess();
              }
            },
            child: Container(
              width: 120,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 24, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    store['nombre'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    store['direccion'] ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Set<Marker>> _createMarkers() async {
    Set<Marker> markers = {};
    
    for (var store in _stores) {
      if (store['latitud'] != null && store['longitud'] != null) {
        final markerId = MarkerId(store['id_tienda'].toString());
        
        // Crear el icono personalizado con el InfoWindow
        final customMarker = await _createCustomMarkerBitmap(
          store['nombre'],
          store['direccion'],
        );

        markers.add(
          Marker(
            markerId: markerId,
            position: LatLng(
              double.parse(store['latitud'].toString()),
              double.parse(store['longitud'].toString()),
            ),
            icon: customMarker,
          ),
        );
      }
    }
    return markers;
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(String title, String address) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(450, 400); // Aumentado para acomodar el ícono grande

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    // Globo de información ajustado
    final bubblePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width - 20, size.height - 200), // Más espacio para el ícono
        Radius.circular(24),
      ));

    // Triángulo más grande
    bubblePath.moveTo(size.width / 2 - 30, size.height - 200);
    bubblePath.lineTo(size.width / 2, size.height - 160);
    bubblePath.lineTo(size.width / 2 + 30, size.height - 200);
    bubblePath.close();

    canvas.drawPath(bubblePath, shadow);
    canvas.drawPath(bubblePath, paint);

    // Texto ajustado
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: size.width - 60);
    titlePainter.paint(canvas, Offset(30, 30));

    final addressPainter = TextPainter(
      text: TextSpan(
        text: address,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 28,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    addressPainter.layout(maxWidth: size.width - 60);
    addressPainter.paint(canvas, Offset(30, 80));

    // Ícono grande de 180x180
    final ByteData iconData = await rootBundle.load('assets/images/store-icon.png');
    final Uint8List iconBytes = iconData.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(
      iconBytes,
      targetWidth: 180,
      targetHeight: 180,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    
    canvas.drawImage(
      fi.image,
      Offset(size.width / 2 - 90, size.height - 180), // Centrado debajo del triángulo
      Paint(),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Widget _buildMapSection() {
    return FutureBuilder<Set<Marker>>(
      future: _createMarkers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Container(
              height: 400, // Aumentado de 150 a 200
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(-33.4489, -70.6693),
                  zoom: 12.8, // Ajustado para mejor vista inicial
                ),
                markers: snapshot.data!,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(stores: _stores),
                        ),
                      );
                    } else {
                      _handleRestrictedAccess();
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _centerMapOnStore(Map<String, dynamic> store) async {
    if (store['latitud'] != null && store['longitud'] != null) {
      try {
        final lat = double.parse(store['latitud'].toString());
        final lng = double.parse(store['longitud'].toString());
        
        await mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(lat, lng),
            16.5, // Ajustado para el nuevo tamaño del marcador
          ),
        );

        await mapController.showMarkerInfoWindow(
          MarkerId(store['id_tienda'].toString())
        );
      } catch (e) {
        print('Error al centrar el mapa: $e');
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !(isPasswordVisible ?? false),
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16, color: AppColors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.secondary.withOpacity(0.7),
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: AppColors.secondary.withOpacity(0.5),
          ),
          filled: true,
          fillColor: AppColors.cream.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accent.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ?? false ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es requerido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginForm(
    TextEditingController emailController,
    TextEditingController passwordController,
    GlobalKey<FormState> formKey,
    bool isPasswordVisible,
    StateSetter setModalState,
  ) {
    bool _isLoading = false;
    
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          _buildInputField(
            controller: emailController,
            label: 'Correo electrónico',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16),
          _buildInputField(
            controller: passwordController,
            label: 'Contraseña',
            icon: Icons.lock,
            isPassword: true,
            isPasswordVisible: isPasswordVisible,
            onTogglePassword: () => setModalState(() => isPasswordVisible = !isPasswordVisible),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                setModalState(() => _isLoading = true);
                try {
                  await _authService.signInWithEmailAndPassword(
                    emailController.text.trim(),
                    passwordController.text,
                  );
                  
                  Navigator.pop(context);
                  setState(() {
                    user = _auth.currentUser;
                  });
                  await _loadInitialData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Inicio de sesión exitoso'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } finally {
                  setModalState(() => _isLoading = false);
                }
              }
            },
            child: _isLoading 
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController nameController,
    GlobalKey<FormState> formKey,
    bool isPasswordVisible,
    StateSetter setModalState,
  ) {
    bool _isLoading = false;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          _buildInputField(
            controller: nameController,
            label: 'Nombre',
            icon: Icons.person,
          ),
          SizedBox(height: 16),
          _buildInputField(
            controller: emailController,
            label: 'Correo electrónico',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16),
          _buildInputField(
            controller: passwordController,
            label: 'Contraseña',
            icon: Icons.lock,
            isPassword: true,
            isPasswordVisible: isPasswordVisible,
            onTogglePassword: () => setModalState(() => isPasswordVisible = !isPasswordVisible),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                setModalState(() => _isLoading = true);
                try {
                  await _authService.registerUser(
                    emailController.text.trim(),
                    passwordController.text,
                    nameController.text.trim(),
                  );

                  Navigator.pop(context);
                  setState(() {
                    user = _auth.currentUser;
                  });
                  _loadInitialData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Registro exitoso'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al registrarse: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } finally {
                  setModalState(() => _isLoading = false);
                }
              }
            },
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:celiapp/services/favorites_service.dart';
import '../widgets/main_scaffold.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/product_card.dart';
import '../constants/app_colors.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _products = [];
  List<dynamic> _stores = [];
  List<dynamic> _filteredProducts = [];
  List<dynamic> _filteredStores = [];
  String _selectedCategory = 'Todas';
  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isGridView = true;
  final user = FirebaseAuth.instance.currentUser;
  List<String> _categories = ['Todas'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Esto forzará la reconstrucción del widget
        _searchController.clear();
        if (_tabController.index == 0) {
          _filteredProducts = _products;
        } else {
          _filteredStores = _stores;
        }
      });
    });
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (_tabController.index == 0) {
        // Búsqueda en productos
        _filteredProducts = _products.where((product) {
          final nombre = product['nombre']?.toString().toLowerCase() ?? '';
          final categoria = product['categoria']?.toString().toLowerCase() ?? '';
          final descripcion = product['descripcion']?.toString().toLowerCase() ?? '';
          
          return nombre.contains(query) ||
                 categoria.contains(query) ||
                 descripcion.contains(query);
        }).toList();
      } else {
        // Búsqueda en tiendas
        _filteredStores = _stores.where((store) {
          final nombre = store['nombre']?.toString().toLowerCase() ?? '';
          final direccion = store['direccion']?.toString().toLowerCase() ?? '';
          final comuna = store['comuna']?.toString().toLowerCase() ?? '';
          final region = store['region']?.toString().toLowerCase() ?? '';
          
          return nombre.contains(query) ||
                 direccion.contains(query) ||
                 comuna.contains(query) ||
                 region.contains(query);
        }).toList();
      }
    });
  }

  void _toggleViewMode() {
    if (_tabController.index == 0) {
      setState(() => _isGridView = !_isGridView);
    }
  }

  Future<void> _fetchData() async {
    try {
      final productsResponse = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos'));
      final storesResponse = await http.get(Uri.parse('http://10.0.2.2:3000/api/tiendas'));
      final categoriesResponse = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos/categorias'));
      
      if (productsResponse.statusCode == 200 && 
          storesResponse.statusCode == 200 && 
          categoriesResponse.statusCode == 200) {
        final products = json.decode(productsResponse.body);
        final stores = json.decode(storesResponse.body);
        final categories = json.decode(categoriesResponse.body);
        
        setState(() {
          _products = products;
          _stores = stores;
          _filteredProducts = products;
          _filteredStores = stores;
          _categories = ['Todas', ...List<String>.from(categories)];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Todas') {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) => 
          product['categoria'].toString() == category
        ).toList();
      }
    });
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          _filterByCategory(selected ? label : 'Todas');
        },
        backgroundColor: isSelected ? Colors.brown[200] : Colors.white,
        selectedColor: Colors.brown[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 13,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
          ),
        ),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget mainContent = Scaffold(
      backgroundColor: isDark ? AppColors.darkBg100 : AppColors.lightBg100,
      body: Column(
        children: [
          // TabBar
          Container(
            color: isDark ? AppColors.darkBg200 : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.brown[200],
              labelColor: isDark ? AppColors.darkText100 : AppColors.lightText100,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Productos'),
                Tab(text: 'Tiendas'),
              ],
            ),
          ),
          // Barra de búsqueda moderna
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.search, color: Colors.grey[400]),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: _tabController.index == 0 
                            ? 'Buscar productos...' 
                            : 'Buscar tiendas...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      onChanged: (_) => _onSearchChanged(),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          if (_tabController.index == 0) {
                            _filteredProducts = _products;
                          } else {
                            _filteredStores = _stores;
                          }
                        });
                      },
                    ),
                  if (_tabController.index == 0)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isGridView ? Icons.list : Icons.grid_view,
                          color: Colors.grey[600],
                        ),
                        onPressed: _toggleViewMode,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_tabController.index == 0)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((category) => 
                  _buildFilterChip(category)
                ).toList(),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    // Grid de productos
                    _buildProductGrid(),
                  ],
                ),
                _buildStoresGrid(),
              ],
            ),
          ),
        ],
      ),
    );

    return MainScaffold(
      currentIndex: 2,
      onAuthenticationRequired: () {},
      body: mainContent,
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_filteredProducts.isEmpty) {
      return Center(child: Text('No se encontraron productos'));
    }

    return Expanded(
      child: _isGridView
          ? GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: _filteredProducts[index],
                  onFavoriteChanged: () {},
                );
              },
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: _filteredProducts[index],
                  isGridView: false,
                  onFavoriteChanged: () {},
                );
              },
            ),
    );
  }

  Widget _buildStoresGrid() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredStores.length,
      itemBuilder: (context, index) {
        final store = _filteredStores[index];
        final direccionCompleta = [
          store['direccion'],
          store['comuna'],
          store['region']
        ].where((item) => item != null && item.toString().isNotEmpty)
            .join(', ');

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.store, size: 40, color: Colors.grey[600]),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store['nombre'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        direccionCompleta,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Solo productos celíacos',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget separado para el botón de favoritos
class FavoriteButton extends StatefulWidget {
  final String productId;
  final String userId;

  FavoriteButton({required this.productId, required this.userId});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await FavoritesService.isFavorite(
      widget.userId,
      widget.productId,
    );
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() => _isFavorite = !_isFavorite);
      bool success;
      
      if (_isFavorite) {
        success = await FavoritesService.addToFavorites(
          widget.userId,
          widget.productId,
        );
      } else {
        success = await FavoritesService.removeFromFavorites(
          widget.userId,
          widget.productId,
        );
      }

      if (!success && mounted) {
        setState(() => _isFavorite = !_isFavorite);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFavorite = !_isFavorite);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: widget.productId),
            ),
          );
        },
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.grey,
          size: 20,
        ),
      ),
    );
  }
  }
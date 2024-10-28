import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/apps_colors.dart';

class ProductCatalogScreen extends StatefulWidget {
  @override
  _ProductCatalogScreenState createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = "";

  // Variables para la paginación
  int _currentPage = 1;
  final int _pageSize = 10; // Número de productos a mostrar por página
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos'));

      if (response.statusCode == 200) {
        setState(() {
          _products = json.decode(response.body);
          _filteredProducts = _products.take(_pageSize * _currentPage).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los productos: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los productos: $e')),
      );
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    // Actualizar la lista de productos mostrados en pantalla
    setState(() {
      _filteredProducts = _products.take(_pageSize * _currentPage).toList();
      _isLoadingMore = false;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = _products.take(_pageSize * _currentPage).toList();
      } else {
        _filteredProducts = _products
            .where((product) => product['nombre'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Catálogo de Productos",
          style: TextStyle(color: AppColors.text100),
        ),
        backgroundColor: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
        iconTheme: IconThemeData(color: AppColors.text100),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(child: Text("No hay productos disponibles"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSearchBar(isDarkMode),
                      SizedBox(height: 10),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                                !_isLoadingMore) {
                              _loadMoreProducts();
                            }
                            return false;
                          },
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15.0,
                              mainAxisSpacing: 15.0,
                              childAspectRatio: 3 / 4, // Cards más altos con proporción más vertical
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              var product = _filteredProducts[index];
                              return _buildProductCard(product, isDarkMode);
                            },
                          ),
                        ),
                      ),
                      if (_isLoadingMore) Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return TextField(
      onChanged: _filterProducts,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
        hintText: 'Buscar productos',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
    );
  }

  Widget _buildProductCard(dynamic product, bool isDarkMode) {
    // Construir la URL de la imagen en Google Cloud Storage usando el ID del producto
    String imageUrl = 'https://storage.googleapis.com/celiapp-bucket/${product['id_producto']}.jpg';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color(0xFFF4CE92), // Color más claro para las tarjetas
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Si la imagen no está disponible, mostrar un marcador de posición
                  return Image.network(
                    'https://via.placeholder.com/150',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['nombre'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  product['descripcion'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

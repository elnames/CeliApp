import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/apps_colors.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos'));

      if (response.statusCode == 200) {
        setState(() {
          _products = json.decode(response.body);
          _filteredProducts = _products;
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

  void _onSearchChanged() {
    setState(() {
      _filteredProducts = _products
          .where((product) => product['nombre']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:3000/api/productos/$id'));

      if (response.statusCode == 200) {
        setState(() {
          _products.removeWhere((product) => product['id_producto'].toString() == id);
          _filteredProducts.removeWhere((product) => product['id_producto'].toString() == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto eliminado exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el producto: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Productos', style: TextStyle(color: AppColors.text100)),
        backgroundColor: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
        iconTheme: IconThemeData(color: AppColors.text100),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.text100),
            onPressed: () {
              Navigator.pushNamed(context, '/product_form').then((_) => _fetchProducts());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          'No hay productos disponibles',
                          style: TextStyle(
                            color: isDarkMode ? AppColors.darkText200 : AppColors.lightText200,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          var product = _filteredProducts[index];
                          return ListTile(
                            title: Text(
                              product['nombre'],
                              style: TextStyle(
                                color: isDarkMode ? AppColors.darkText100 : AppColors.lightText100,
                              ),
                            ),
                            subtitle: Text(
                              product['descripcion'],
                              style: TextStyle(
                                color: isDarkMode ? AppColors.darkText200 : AppColors.lightText200,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: AppColors.lightAccent100),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/product_edit',
                                      arguments: product,
                                    ).then((_) => _fetchProducts());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(product['id_producto'].toString()),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/product_details', arguments: product);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/apps_colors.dart'; // Asegúrate de que esta ruta sea correcta

class StoreCatalogScreen extends StatefulWidget {
  @override
  _StoreCatalogScreenState createState() => _StoreCatalogScreenState();
}

class _StoreCatalogScreenState extends State<StoreCatalogScreen> {
  List<dynamic> _stores = [];
  List<dynamic> _filteredStores = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStores();
    _searchController.addListener(_filterStores);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStores() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/tiendas'));

      if (response.statusCode == 200) {
        setState(() {
          _stores = json.decode(response.body);
          _filteredStores = _stores;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las tiendas: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las tiendas: $e')),
      );
    }
  }

  void _filterStores() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredStores = _stores;
      } else {
        _filteredStores = _stores.where((store) {
          final storeName = store['nombre']?.toLowerCase() ?? '';
          final searchQuery = _searchController.text.toLowerCase();
          return storeName.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Catálogo de Tiendas"),
        backgroundColor: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
                      hintText: 'Buscar tienda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _filteredStores.isEmpty
                        ? Center(child: Text("No hay tiendas disponibles"))
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                            ),
                            itemCount: _filteredStores.length,
                            itemBuilder: (context, index) {
                              var store = _filteredStores[index];
                              return _buildStoreCard(store, isDarkMode);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStoreCard(dynamic store, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/store_details', arguments: store['id_tienda']);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  store['image'] ?? 'https://via.placeholder.com/150',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['nombre'] ?? 'Tienda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    store['direccion'] ?? 'Dirección no disponible',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

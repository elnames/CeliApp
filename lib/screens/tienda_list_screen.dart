import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/apps_colors.dart';

class TiendaListScreen extends StatefulWidget {
  const TiendaListScreen({Key? key}) : super(key: key);

  @override
  _TiendaListScreenState createState() => _TiendaListScreenState();
}

class _TiendaListScreenState extends State<TiendaListScreen> {
  List<dynamic> _tiendas = [];
  List<dynamic> _filteredTiendas = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTiendas();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTiendas() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/tiendas'));

      if (response.statusCode == 200) {
        setState(() {
          _tiendas = json.decode(response.body);
          _filteredTiendas = _tiendas;
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

  void _onSearchChanged() {
    setState(() {
      _filteredTiendas = _tiendas
          .where((tienda) => tienda['nombre']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteTienda(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:3000/api/tiendas/$id'));

      if (response.statusCode == 200) {
        setState(() {
          _tiendas.removeWhere((tienda) => tienda['id_tienda'].toString() == id);
          _filteredTiendas.removeWhere((tienda) => tienda['id_tienda'].toString() == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tienda eliminada exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la tienda: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la tienda: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tiendas', style: TextStyle(color: AppColors.text100)),
        backgroundColor: isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
        iconTheme: IconThemeData(color: AppColors.text100),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.text100),
            onPressed: () {
              Navigator.pushNamed(context, '/tienda_form').then((_) => _fetchTiendas());
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
                hintText: 'Buscar tiendas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredTiendas.isEmpty
                    ? Center(
                        child: Text(
                          'No hay tiendas disponibles',
                          style: TextStyle(
                            color: isDarkMode ? AppColors.darkText200 : AppColors.lightText200,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredTiendas.length,
                        itemBuilder: (context, index) {
                          var tienda = _filteredTiendas[index];
                          return ListTile(
                            title: Text(
                              tienda['nombre'],
                              style: TextStyle(
                                color: isDarkMode ? AppColors.darkText100 : AppColors.lightText100,
                              ),
                            ),
                            subtitle: Text(
                              tienda['direccion'],
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
                                      '/tienda_edit',
                                      arguments: tienda,
                                    ).then((_) => _fetchTiendas());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTienda(tienda['id_tienda'].toString()),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/tienda_details', arguments: tienda);
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

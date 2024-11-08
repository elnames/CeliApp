import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_colors.dart';

class StoreManagementScreen extends StatefulWidget {
  @override
  _StoreManagementScreenState createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  List<dynamic> _tiendas = [];
  List<String> _regiones = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTiendas();
    _fetchRegiones();
  }

  Future<void> _fetchTiendas() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/tiendas'));
      if (response.statusCode == 200) {
        setState(() {
          _tiendas = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar tiendas: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchRegiones() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/tiendas/regiones'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _regiones = List<String>.from(data);
          if (!_regiones.contains('Sin región')) {
            _regiones.add('Sin región');
          }
        });
      }
    } catch (e) {
      print('Error al cargar regiones: $e');
      setState(() {
        _regiones = ['Sin región'];
      });
    }
  }

  Future<void> _showStoreDialog([Map<String, dynamic>? tienda]) async {
    final isEditing = tienda != null;
    final nombreController = TextEditingController(text: tienda?['nombre'] ?? '');
    final direccionController = TextEditingController(text: tienda?['direccion'] ?? '');
    final latitudController = TextEditingController(text: tienda?['latitud']?.toString() ?? '');
    final longitudController = TextEditingController(text: tienda?['longitud']?.toString() ?? '');
    final comunaController = TextEditingController(text: tienda?['comuna'] ?? '');
    String selectedRegion = tienda?['region'] ?? (_regiones.isNotEmpty ? _regiones[0] : 'Sin región');

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Tienda' : 'Nueva Tienda'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: direccionController,
                      decoration: InputDecoration(labelText: 'Dirección'),
                    ),
                    TextField(
                      controller: comunaController,
                      decoration: InputDecoration(labelText: 'Comuna'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedRegion,
                      decoration: InputDecoration(labelText: 'Región'),
                      items: _regiones.map((String region) {
                        return DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() => selectedRegion = newValue!);
                      },
                    ),
                    TextField(
                      controller: latitudController,
                      decoration: InputDecoration(labelText: 'Latitud'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextField(
                      controller: longitudController,
                      decoration: InputDecoration(labelText: 'Longitud'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(isEditing ? 'Guardar' : 'Crear'),
                  onPressed: () => _saveStore(
                    tienda?['id_tienda'],
                    {
                      'nombre': nombreController.text,
                      'direccion': direccionController.text,
                      'comuna': comunaController.text,
                      'region': selectedRegion,
                      'latitud': double.tryParse(latitudController.text),
                      'longitud': double.tryParse(longitudController.text),
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg100 : AppColors.lightBg100,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg200 : AppColors.lightBg200,
        title: Text(
          'Gestión de Tiendas',
          style: TextStyle(
            color: isDark ? AppColors.darkText100 : AppColors.lightText100,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black87),
            onPressed: () => _showStoreDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar tiendas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tiendas.length,
                    itemBuilder: (context, index) {
                      final tienda = _tiendas[index];
                      if (_searchController.text.isNotEmpty &&
                          !tienda['nombre'].toString().toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              )) {
                        return Container();
                      }
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(tienda['nombre']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tienda['direccion']),
                              Text('${tienda['comuna']}, ${tienda['region']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Color(0xFF7895B2)),
                                onPressed: () => _showStoreDialog(tienda),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[300]),
                                onPressed: () => _showDeleteConfirmation(tienda['id_tienda'].toString()),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta tienda?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Eliminar'),
              onPressed: () async {
                try {
                  final response = await http.delete(
                    Uri.parse('http://10.0.2.2:3000/api/tiendas/$id'),
                  );
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    _fetchTiendas();
                    _showSuccessSnackBar('Tienda eliminada');
                  }
                } catch (e) {
                  _showErrorSnackBar('Error al eliminar: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _saveStore(String? id, Map<String, dynamic> storeData) async {
    try {
      final response = id != null
          ? await http.put(
              Uri.parse('http://10.0.2.2:3000/api/tiendas/$id'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(storeData),
            )
          : await http.post(
              Uri.parse('http://10.0.2.2:3000/api/tiendas'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(storeData),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        _fetchTiendas();
        _showSuccessSnackBar(
          id != null ? 'Tienda actualizada' : 'Tienda creada',
        );
      } else {
        _showErrorSnackBar('Error al ${id != null ? 'actualizar' : 'crear'} la tienda');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_colors.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<dynamic> _productos = [];
  List<String> _categorias = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProductos();
    _fetchCategorias();
  }

  Future<void> _fetchProductos() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos'));
      if (response.statusCode == 200) {
        setState(() {
          _productos = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al cargar productos: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchCategorias() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos/categorias'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _categorias = List<String>.from(data);
          if (!_categorias.contains('Sin categoría')) {
            _categorias.add('Sin categoría');
          }
        });
        print('Categorías cargadas: $_categorias');
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        setState(() {
          _categorias = ['Sin categoría'];
        });
      }
    } catch (e) {
      print('Error al cargar categorías: $e');
      setState(() {
        _categorias = ['Sin categoría'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg100 : AppColors.lightBg100,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg200 : AppColors.lightBg200,
        title: Text(
          'Gestión de Productos',
          style: TextStyle(
            color: isDark ? AppColors.darkText100 : AppColors.lightText100,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black87),
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body: Container(
        color: isDark ? AppColors.darkBg100 : AppColors.lightBg100,
        child: Column(
          children: [
            Container(
              color: isDark ? AppColors.darkBg200 : Colors.white,
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor: isDark ? AppColors.darkBg100 : Colors.grey[100],
                  filled: true,
                  hintText: 'Buscar productos...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? AppColors.darkText100 : AppColors.lightText100,
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        if (_searchController.text.isNotEmpty &&
                            !producto['nombre']
                                .toString()
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase())) {
                          return Container();
                        }
                        return _buildProductCard(producto);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> producto) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_drink, color: Colors.blue[300], size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto['nombre'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          producto['categoria'] ?? 'Sin categoría',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (producto['prod_celiaco'] == true)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Celíaco',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue[300], size: 20),
                  constraints: BoxConstraints(
                    minWidth: 35,
                    minHeight: 35,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => _showProductDialog(producto),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[300], size: 20),
                  constraints: BoxConstraints(
                    minWidth: 35,
                    minHeight: 35,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => _showDeleteConfirmation(producto['id_producto'].toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProductDialog([Map<String, dynamic>? producto]) async {
    if (_categorias.isEmpty) {
      await _fetchCategorias();
    }

    final isEditing = producto != null;
    final nombreController = TextEditingController(text: producto?['nombre'] ?? '');
    final descripcionController = TextEditingController(text: producto?['descripcion'] ?? '');
    final empresaController = TextEditingController(text: producto?['empresa_tienda'] ?? '');
    final codigoBarrasController = TextEditingController(text: producto?['codigo_barras'] ?? '');
    final urlImagenController = TextEditingController(text: producto?['url_imagen'] ?? '');
    
    String selectedCategoria = producto?['categoria'] ?? 
        (_categorias.isNotEmpty ? _categorias[0] : 'Sin categoría');
    bool isCeliaco = producto?['prod_celiaco'] ?? false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(selectedCategoria).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryEmoji(selectedCategoria),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextField(
                        controller: descripcionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextField(
                        controller: empresaController,
                        decoration: InputDecoration(
                          labelText: 'Empresa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextField(
                        controller: codigoBarrasController,
                        decoration: InputDecoration(
                          labelText: 'Código de Barras',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextField(
                        controller: urlImagenController,
                        decoration: InputDecoration(
                          labelText: 'URL de Imagen',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<String>(
                          value: selectedCategoria,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            border: InputBorder.none,
                          ),
                          items: _categorias.map((String categoria) {
                            return DropdownMenuItem<String>(
                              value: categoria,
                              child: Text(
                                categoria,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCategoria = newValue;
                              });
                            }
                          },
                          isExpanded: true,
                          menuMaxHeight: 300,
                        ),
                      ),
                      SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Producto Celíaco',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              Switch(
                                value: isCeliaco,
                                onChanged: (bool value) {
                                  setState(() {
                                    isCeliaco = value;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7895B2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(isEditing ? 'Guardar' : 'Crear'),
                  onPressed: () async {
                    final productoData = {
                      'nombre': nombreController.text,
                      'descripcion': descripcionController.text,
                      'categoria': selectedCategoria,
                      'empresa_tienda': empresaController.text,
                      'prod_celiaco': isCeliaco,
                      'codigo_barras': codigoBarrasController.text,
                      'url_imagen': urlImagenController.text,
                    };

                    try {
                      final response = isEditing
                          ? await http.put(
                              Uri.parse('http://10.0.2.2:3000/api/productos/${producto!['id_producto']}'),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode(productoData),
                            )
                          : await http.post(
                              Uri.parse('http://10.0.2.2:3000/api/productos'),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode(productoData),
                            );

                      if (response.statusCode == 200 || response.statusCode == 201) {
                        Navigator.pop(context);
                        _fetchProductos();
                        _showSuccessSnackBar(
                          isEditing ? 'Producto actualizado' : 'Producto creado',
                        );
                      }
                    } catch (e) {
                      _showErrorSnackBar('Error: $e');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(String id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este producto?'),
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
                    Uri.parse('http://10.0.2.2:3000/api/productos/$id'),
                  );
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    _fetchProductos();
                    _showSuccessSnackBar('Producto eliminado');
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

  String _getCategoryEmoji(String? category) {
    switch (category?.toLowerCase()) {
      case 'bebidas y jugos':
        return '🥤';
      case 'carnes':
        return '🥩';
      case 'cereales para desayuno y barras de cereal':
        return '🥣';
      case 'cerveza y licores':
        return '🍺';
      case 'chocolates y coberturas':
        return '🍫';
      case 'cóctel y snacks':
        return '🥨';
      case 'galletas':
        return '🍪';
      case 'helados':
        return '🍦';
      case 'leches':
        return '🥛';
      case 'panes y productos horneados y pastelería':
        return '🥖';
      case 'postres y compotas':
        return '🍮';
      case 'yogurt y leche cultivada':
        return '🥛';
      default:
        return '🍽️';
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'bebidas y jugos':
        return Colors.blue;
      case 'carnes':
        return Colors.red;
      case 'cereales para desayuno y barras de cereal':
        return Colors.orange;
      case 'cerveza y licores':
        return Colors.amber;
      case 'chocolates y coberturas':
        return Colors.brown;
      case 'cóctel y snacks':
        return Colors.purple;
      case 'galletas':
        return Colors.orange;
      case 'helados':
        return Colors.lightBlue;
      case 'leches':
        return Colors.cyan;
      case 'panes y productos horneados y pastelería':
        return Colors.brown;
      case 'postres y compotas':
        return Colors.pink;
      case 'yogurt y leche cultivada':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
} 
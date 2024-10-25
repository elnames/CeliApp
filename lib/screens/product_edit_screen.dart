import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/apps_colors.dart';

class ProductEditScreen extends StatefulWidget {
  final dynamic product;

  const ProductEditScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductEditScreenState createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _codigoBarrasController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores con los valores del producto
    _nombreController.text = widget.product['nombre'] ?? '';
    _descripcionController.text = widget.product['descripcion'] ?? '';
    _empresaController.text = widget.product['empresa_tienda'] ?? '';
    _codigoBarrasController.text = widget.product['codigo_barras'] ?? '';
  }

  @override
  void dispose() {
    // Liberar los controladores cuando se desmonte el widget
    _nombreController.dispose();
    _descripcionController.dispose();
    _empresaController.dispose();
    _codigoBarrasController.dispose();
    super.dispose();
  }

  Future<void> _editProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Mostrar indicador de carga
      });

      final updatedProduct = {
        "nombre": _nombreController.text,
        "descripcion": _descripcionController.text,
        "empresa_tienda": _empresaController.text,
        "codigo_barras": _codigoBarrasController.text,
        "prod_celiaco": widget.product['prod_celiaco'],
      };

      try {
        // Verifica si el ID del producto es válido
        final productId = widget.product['id_producto'];
        if (productId == null || productId == "") {
          throw Exception("El ID del producto no es válido.");
        }

        // Realiza la solicitud PUT
        final response = await http.put(
          Uri.parse('http://10.0.2.2:3000/api/productos/$productId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedProduct),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto actualizado exitosamente')),
          );
        } else if (response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto no encontrado. Verifica el ID')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar producto: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar producto: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Ocultar indicador de carga
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Producto'),
        backgroundColor: AppColors.lightPrimary100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _empresaController,
                decoration: InputDecoration(labelText: 'Empresa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la empresa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _codigoBarrasController,
                decoration: InputDecoration(labelText: 'Código de Barras'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un código de barras';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _editProduct,
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

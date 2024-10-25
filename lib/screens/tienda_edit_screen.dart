import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/apps_colors.dart';

class TiendaEditScreen extends StatefulWidget {
  final dynamic tienda;

  const TiendaEditScreen({Key? key, required this.tienda}) : super(key: key);

  @override
  _TiendaEditScreenState createState() => _TiendaEditScreenState();
}

class _TiendaEditScreenState extends State<TiendaEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores con los valores de la tienda
    _nombreController.text = widget.tienda['nombre'] ?? '';
    _direccionController.text = widget.tienda['direccion'] ?? '';
    _latitudController.text = widget.tienda['latitud'].toString() ?? '';
    _longitudController.text = widget.tienda['longitud'].toString() ?? '';
  }

  @override
  void dispose() {
    // Liberar los controladores cuando se desmonte el widget
    _nombreController.dispose();
    _direccionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  Future<void> _editTienda() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Mostrar indicador de carga
      });

      final updatedTienda = {
        "nombre": _nombreController.text,
        "direccion": _direccionController.text,
        "latitud": double.tryParse(_latitudController.text),
        "longitud": double.tryParse(_longitudController.text),
      };

      try {
        final response = await http.put(
          Uri.parse('http://10.0.2.2:3000/api/tiendas/${widget.tienda['id_tienda']}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedTienda),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tienda actualizada exitosamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar tienda: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar tienda: $e')),
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
        title: Text('Editar Tienda'),
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
                decoration: InputDecoration(labelText: 'Nombre de la Tienda'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una dirección';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _latitudController,
                decoration: InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una latitud';
                  }
                  final double? latitud = double.tryParse(value);
                  if (latitud == null || latitud < -90 || latitud > 90) {
                    return 'Ingrese una latitud válida entre -90 y 90';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudController,
                decoration: InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una longitud';
                  }
                  final double? longitud = double.tryParse(value);
                  if (longitud == null || longitud < -180 || longitud > 180) {
                    return 'Ingrese una longitud válida entre -180 y 180';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _editTienda,
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

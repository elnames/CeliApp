// user_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSettingsScreen extends StatefulWidget {
  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  User? user;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración de la Cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Correo del usuario'),
              subtitle: Text(user?.email ?? 'No disponible'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Nombre del usuario'),
              subtitle: Text(user?.displayName ?? 'No disponible'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editNameDialog();
                },
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Cambiar contraseña'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editPasswordDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editNameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar nombre'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: "Nuevo nombre"),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  try {
                    await user?.updateDisplayName(_nameController.text);
                    await user?.reload();
                    user = FirebaseAuth.instance.currentUser;
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Nombre actualizado con éxito')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar el nombre: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cambiar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(hintText: "Contraseña actual"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(hintText: "Nueva contraseña"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(hintText: "Confirmar nueva contraseña"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                if (_currentPasswordController.text.isEmpty ||
                    _newPasswordController.text.isEmpty ||
                    _confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Todos los campos son obligatorios.'),
                  ));
                  return;
                }

                if (_newPasswordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Las contraseñas nuevas no coinciden.'),
                  ));
                  return;
                }

                try {
                  // Reautenticar al usuario antes de cambiar la contraseña
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: _currentPasswordController.text,
                  );
                  await user!.reauthenticateWithCredential(credential);

                  // Actualizar la contraseña
                  await user!.updatePassword(_newPasswordController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña actualizada con éxito')),
                  );

                  // Limpiar campos
                  _currentPasswordController.clear();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar la contraseña: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

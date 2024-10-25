// user_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  _UserSettingsScreenState createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  User? user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
        title: const Text('Configuración de la Cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Correo del usuario'),
              subtitle: Text(user?.email ?? 'No disponible'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nombre del usuario'),
              subtitle: Text(user?.displayName ?? 'No disponible'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editNameDialog();
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Cambiar contraseña'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
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
          title: const Text('Editar nombre'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: "Nuevo nombre"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  try {
                    await user?.updateDisplayName(_nameController.text);
                    await user?.reload();
                    user = FirebaseAuth.instance.currentUser;
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Nombre actualizado con éxito')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error al actualizar el nombre: $e')),
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
          title: const Text('Cambiar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(hintText: "Contraseña actual"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Nueva contraseña"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: "Confirmar nueva contraseña"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (_currentPasswordController.text.isEmpty ||
                    _newPasswordController.text.isEmpty ||
                    _confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Todos los campos son obligatorios.'),
                  ));
                  return;
                }

                if (_newPasswordController.text !=
                    _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
                    const SnackBar(
                        content: Text('Contraseña actualizada con éxito')),
                  );

                  // Limpiar campos
                  _currentPasswordController.clear();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error al actualizar la contraseña: $e')),
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

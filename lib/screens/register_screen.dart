import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/apps_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Registrar el usuario con Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        // Actualizar el nombre del usuario y guardar en Firestore
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          await user.reload();
          User? updatedUser = _auth.currentUser;

          setState(() {
            _auth.currentUser == updatedUser;
          });

          // Guardar los datos del usuario en Firestore con rol predeterminado 'user'
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'name': _nameController.text.trim(),
            'role': 'user', // Rol predeterminado
            'createdAt': FieldValue.serverTimestamp(),
          });

          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro', style: TextStyle(color: AppColors.text100)),
        backgroundColor:
            isDarkMode ? AppColors.darkPrimary100 : AppColors.lightPrimary100,
        iconTheme: IconThemeData(color: AppColors.text100),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.darkBg100, AppColors.darkBg200]
                : [AppColors.lightBg100, AppColors.lightBg200],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  color:
                      isDarkMode ? AppColors.darkBg300 : AppColors.lightBg300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: isDarkMode
                                ? AppColors.darkAccent100
                                : AppColors.lightAccent100,
                            child: Icon(Icons.person_add,
                                size: 40, color: AppColors.text100),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              labelStyle: TextStyle(
                                  color: isDarkMode
                                      ? AppColors.darkText200
                                      : AppColors.lightText200),
                              prefixIcon: Icon(Icons.person,
                                  color: isDarkMode
                                      ? AppColors.darkAccent200
                                      : AppColors.lightAccent200),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? AppColors.darkPrimary200
                                        : AppColors.lightPrimary200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? AppColors.darkAccent100
                                        : AppColors.lightAccent100),
                              ),
                              fillColor: isDarkMode
                                  ? AppColors.darkBg200
                                  : AppColors.lightBg200,
                              filled: true,
                            ),
                            style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.darkText100
                                    : AppColors.lightText100),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Correo',
                              labelStyle: TextStyle(
                                  color: isDarkMode
                                      ? AppColors.darkText200
                                      : AppColors.lightText200),
                              prefixIcon: Icon(Icons.email,
                                  color: isDarkMode
                                      ? AppColors.darkAccent200
                                      : AppColors.lightAccent200),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? AppColors.darkPrimary200
                                        : AppColors.lightPrimary200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? AppColors.darkAccent100
                                        : AppColors.lightAccent100),
                              ),
                              fillColor: isDarkMode
                                  ? AppColors.darkBg200
                                  : AppColors.lightBg200,
                              filled: true,
                            ),
                            style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.darkText100
                                    : AppColors.lightText100),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo';
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Por favor ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(
                                  color: isDarkMode
                                      ? AppColors.darkText200
                                      : AppColors.lightText200),
                              prefixIcon: Icon(Icons.lock,
                                  color: isDarkMode
                                      ? AppColors.darkAccent200
                                      : AppColors.lightAccent200),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? AppColors.darkPrimary200
                                        : AppColors.lightPrimary200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? AppColors.darkAccent100
                                        : AppColors.lightAccent100),
                              ),
                              fillColor: isDarkMode
                                  ? AppColors.darkBg200
                                  : AppColors.lightBg200,
                              filled: true,
                            ),
                            style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.darkText100
                                    : AppColors.lightText100),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              } else if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? AppColors.darkAccent100
                                    : AppColors.lightAccent100,
                                foregroundColor: AppColors.text100,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: AppColors.text100)
                                  : Text('REGISTRARSE',
                                      style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('¿Ya tienes una cuenta? Inicia sesión',
                                style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.darkAccent200
                                        : AppColors.lightAccent200)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/home');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? AppColors.darkPrimary200
                                  : AppColors.lightPrimary200,
                              foregroundColor: AppColors.text100,
                            ),
                            child: Text('Volver al Inicio'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

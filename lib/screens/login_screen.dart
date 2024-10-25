import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/apps_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Iniciar Sesión',
          style: TextStyle(color: AppColors.text100),
        ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: isDarkMode
                              ? AppColors.darkAccent100
                              : AppColors.lightAccent100,
                          child: Icon(Icons.person,
                              size: 40, color: AppColors.text100),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
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
                        ),
                        const SizedBox(height: 16),
                        TextField(
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
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                  activeColor: isDarkMode
                                      ? AppColors.darkAccent100
                                      : AppColors.lightAccent100,
                                  checkColor: AppColors.text100,
                                ),
                                Text(
                                  'Recuérdame',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.darkText200
                                        : AppColors.lightText200,
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () {
                                  // Implementa la lógica de "Olvidé mi contraseña"
                                },
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.darkAccent200
                                        : AppColors.lightAccent200,
                                    overflow: TextOverflow
                                        .ellipsis, // Si el texto es muy largo
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? AppColors.darkAccent100
                                  : AppColors.lightAccent100,
                              foregroundColor: AppColors.text100,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: AppColors.text100)
                                : Text('Iniciar sesión',
                                    style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          child: Text('¿No tienes cuenta? Regístrate.',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? AppColors.darkAccent200
                                      : AppColors.lightAccent200)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/home');
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
    );
  }
}

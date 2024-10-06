// home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Eliminar el ícono de volver
        title: Text('CeliApp'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return user != null ? _authenticatedMenu(context) : _guestMenu(context);
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              user != null
                  ? 'Hola ${user!.displayName ?? 'Usuario'}, ¿Qué estás buscando hoy?'
                  : 'Hola Invitado, ¿Qué estás buscando hoy?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Busca tu local o comida favorita',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Comida recomendada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildProductCard(context, index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Locales cercanos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: _buildMapSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          Navigator.pushNamed(context, '/product_details', arguments: index);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Debes iniciar sesión para ver los detalles del producto.')),
          );
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network('https://via.placeholder.com/150', height: 100, width: 100),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Producto $index',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Descripción del producto',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          Navigator.pushNamed(context, '/map');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Debes iniciar sesión para acceder al mapa de locales cercanos.')),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.all(16.0),
        color: Colors.grey[300],
        height: 150,
        child: Center(child: Text('Mapa de locales cercanos', style: TextStyle(fontSize: 18))),
      ),
    );
  }

  Widget _authenticatedMenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Configuración de la cuenta'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/user_settings');
          },
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Cerrar sesión'),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            setState(() {
              user = null;
            });
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ],
    );
  }

  Widget _guestMenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.login),
          title: Text('Iniciar sesión'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/login');
          },
        ),
        ListTile(
          leading: Icon(Icons.app_registration),
          title: Text('Registrarse'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/register');
          },
        ),
      ],
    );
  }
}

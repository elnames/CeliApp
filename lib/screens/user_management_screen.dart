import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> users = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      setState(() {
        users = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print('Datos del usuario: $data');

          return {
            'id': doc.id,
            'displayName': data['name'] ?? data['displayName'] ?? 'Sin nombre',
            'email': data['email'] ?? '',
            'role': data['role'] ?? 'user',
            'isSubscribed': data['isSubscribed'] ?? false,
          };
        }).toList();
        
        print('Usuarios cargados: $users');
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar usuarios: $e');
      setState(() => isLoading = false);
      _showErrorSnackBar('Error al cargar usuarios: $e');
    }
  }

  Future<void> _updateUser(String userId, String displayName, String role, bool isSubscribed) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': displayName,
        'displayName': displayName,
        'role': role,
        'isSubscribed': isSubscribed,
      });
      
      await _loadUsers();
      _showSuccessSnackBar('Usuario actualizado exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al actualizar usuario: $e');
    }
  }

  Future<void> _showUserDialog(Map<String, dynamic> user) async {
    final nameController = TextEditingController(text: user['displayName'] ?? 'Sin nombre');
    String selectedRole = user['role'] ?? 'user';
    bool isSubscribed = user['isSubscribed'] ?? false;

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
                      color: (selectedRole == 'admin' ? Colors.purple : Colors.blue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: selectedRole == 'admin' ? Colors.purple : Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Editar Usuario'),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextField(
                        controller: TextEditingController(text: user['email']),
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Email (no editable)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
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
                          value: selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Rol',
                            border: InputBorder.none,
                          ),
                          items: ['user', 'admin'].map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(
                                role == 'admin' ? 'Administrador' : 'Usuario',
                                style: TextStyle(
                                  color: role == 'admin' ? Colors.purple : Colors.blue,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => selectedRole = newValue);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, 
                                  color: isSubscribed ? Colors.amber : Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('Suscripción',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isSubscribed,
                              onChanged: (bool value) {
                                setState(() => isSubscribed = value);
                              },
                              activeColor: Colors.amber,
                            ),
                          ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Guardar'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _updateUser(
                      user['id'],
                      nameController.text,
                      selectedRole,
                      isSubscribed,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateUserDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'user';
    bool isSubscribed = false;

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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.person_add, color: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Crear Usuario'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          border: InputBorder.none,
                        ),
                        items: ['user', 'admin'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(
                              role == 'admin' ? 'Administrador' : 'Usuario',
                              style: TextStyle(
                                color: role == 'admin' ? Colors.purple : Colors.blue,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => selectedRole = newValue);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, 
                                color: isSubscribed ? Colors.amber : Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text('Suscripción'),
                            ],
                          ),
                          Switch(
                            value: isSubscribed,
                            onChanged: (bool value) {
                              setState(() => isSubscribed = value);
                            },
                            activeColor: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Crear'),
                  onPressed: () async {
                    try {
                      // Crear usuario en Authentication
                      final UserCredential userCredential = 
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                      );

                      // Crear documento en Firestore
                      await _firestore.collection('users').doc(userCredential.user!.uid).set({
                        'name': nameController.text.trim(),
                        'displayName': nameController.text.trim(),
                        'email': emailController.text.trim(),
                        'role': selectedRole,
                        'isSubscribed': isSubscribed,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(context);
                      _loadUsers();
                      _showSuccessSnackBar('Usuario creado exitosamente');
                    } catch (e) {
                      _showErrorSnackBar('Error al crear usuario: $e');
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

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final searchTerm = _searchController.text.toLowerCase();
      final name = (user['displayName'] ?? 'Sin nombre').toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      return name.contains(searchTerm) || email.contains(searchTerm);
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gestión de Usuarios',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadUsers,
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
                hintText: 'Buscar usuarios...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final bool isAdmin = user['role'] == 'admin';
                      
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
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: isAdmin ? Colors.purple[100] : Colors.blue[100],
                            child: Icon(
                              Icons.person,
                              color: isAdmin ? Colors.purple : Colors.blue,
                            ),
                          ),
                          title: Text(
                            user['displayName'] ?? 'Sin nombre',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['email'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isAdmin ? Colors.purple[50] : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isAdmin ? 'Administrador' : 'Usuario',
                                  style: TextStyle(
                                    color: isAdmin ? Colors.purple : Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: Color(0xFF7895B2)),
                            onPressed: () => _showUserDialog(user),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(),
        backgroundColor: Color(0xFF7895B2),
        child: Icon(Icons.person_add),
      ),
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
} 
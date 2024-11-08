import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'displayName': name,
          'role': 'user',
          'isSubscribed': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        await updateLastLogin();
      }
    } catch (e) {
      print("Error en registro: $e");
      throw e;
    }
  }

  Future<bool> isUserAdmin() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists && (userDoc.data() as Map<String, dynamic>)['role'] == 'admin';
    }
    return false;
  }

  Future<bool> isUserSubscribed() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['isSubscribed'] ?? false;
      }
    }
    return false;
  }

  Future<void> updateLastLogin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Actualizar último login
      await updateLastLogin();
      
      return userCredential;
    } catch (e) {
      print("Error en login: $e");
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw 'No existe una cuenta con este correo';
          case 'wrong-password':
            throw 'Contraseña incorrecta';
          case 'invalid-email':
            throw 'Correo electrónico inválido';
          default:
            throw 'Error de autenticación: ${e.message}';
        }
      }
      throw 'Error al iniciar sesión';
    }
  }
}

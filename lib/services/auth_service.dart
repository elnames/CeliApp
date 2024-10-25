import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(String email, String password) async {
    try {
      // Crear usuario con Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtener el UID del usuario registrado
      User? user = userCredential.user;

      // Si el usuario fue creado exitosamente, agregamos el documento a Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'role': 'user' // El rol predeterminado es "user"
        });

        print("Usuario añadido a Firestore con éxito.");
      }
    } catch (e) {
      print("Error al registrar el usuario: $e");
    }
  }

  Future<bool> isUserAdmin() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc['role'] == 'admin') {
        return true;
      }
    }
    return false;
  }
}

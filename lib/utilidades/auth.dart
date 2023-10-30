import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges(); // Cambio realizado aquí

  Future<User?> registrarEmailPass(String email, String pass) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return userCredential.user;
    } catch (e) {
      print("Error al registrar: $e");
      return null;
    }
  }

  Future<User?> iniciarSesionEmailPass(String email, String pass) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return userCredential.user;
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olivos_verdes/models/usuario_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
    required String direccion,
    String? telefono,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombre': nombre,
        'correo': email,
        'rol': 'cliente',
        'direccion': direccion,
        'telefono': telefono,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      return "success";
    } catch (e) {
      final error = e as FirebaseAuthException;
      switch (error.code) {
        case 'email-already-in-use':
          return 'El correo ya está registrado';
        case 'weak-password':
          return 'Contraseña muy débil (mínimo 6 caracteres)';
        default:
          return error.message ?? 'Error al registrarse';
      }
    }
  }

  Future<String?> loginUsuario(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } catch (e) {
      final error = e as FirebaseAuthException;
      switch (error.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          return 'Correo o contraseña incorrectos';
        default:
          return error.message ?? 'Error al iniciar sesión';
      }
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  Future<void> enviarCorreoRecuperacion(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<Usuario?> obtenerUsuario(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return Usuario.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> actualizarPerfil(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('usuarios').doc(uid).update(data);
  }
}

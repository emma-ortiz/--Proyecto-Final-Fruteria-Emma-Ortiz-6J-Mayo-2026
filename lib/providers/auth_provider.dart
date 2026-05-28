import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olivos_verdes/services/auth_service.dart';
import 'package:olivos_verdes/models/usuario_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Usuario? _user;
  bool _loading = true;
  String? _error;

  Usuario? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.rol == 'admin';

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    _loading = true;
    notifyListeners();

    if (firebaseUser != null) {
      try {
        _user = await _authService.obtenerUsuario(firebaseUser.uid);
      } catch (e) {
        _user = null;
      }
    } else {
      _user = null;
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    notifyListeners();

    final result = await _authService.loginUsuario(email, password);
    if (result != "success") {
      _error = result;
      notifyListeners();
      return false;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        _user = await _authService.obtenerUsuario(currentUser.uid);
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        return false;
      }
    }

    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    required String direccion,
    String? telefono,
  }) async {
    _error = null;
    notifyListeners();

    final result = await _authService.registrarUsuario(
      nombre: nombre,
      email: email,
      password: password,
      direccion: direccion,
      telefono: telefono,
    );
    if (result != "success") {
      _error = result;
      notifyListeners();
      return false;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        _user = await _authService.obtenerUsuario(currentUser.uid);
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        return false;
      }
    }

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _error = null;
    await _authService.cerrarSesion();
    _user = null;
    notifyListeners();
  }

  Future<void> refrescarUsuario() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = await _authService.obtenerUsuario(currentUser.uid);
      notifyListeners();
    }
  }

  Future<void> actualizarPerfil(Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    await _authService.actualizarPerfil(currentUser.uid, data);
    await refrescarUsuario();
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _authService.enviarCorreoRecuperacion(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

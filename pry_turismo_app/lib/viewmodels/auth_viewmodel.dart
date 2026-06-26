import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? usuario;
  bool cargando = false;
  String mensaje = '';

  AuthViewModel() {
    _authService.authStateChanges.listen((User? user) {
      usuario = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    cargando = true;
    mensaje = '';
    notifyListeners();

    try {
      usuario = await _authService.signInWithGoogle();

      if (usuario != null) {
        mensaje = 'Sesión iniciada correctamente con Google';
      } else {
        mensaje = 'Inicio de sesión cancelado';
      }
    } catch (e) {
      mensaje = 'Error al iniciar sesión con Google: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      mensaje = 'Por favor ingresa correo y contraseña';
      notifyListeners();
      return;
    }

    cargando = true;
    mensaje = '';
    notifyListeners();

    try {
      usuario = await _authService.signInWithEmailAndPassword(email, password);

      if (usuario != null) {
        mensaje = 'Sesión iniciada correctamente';
      }
    } catch (e) {
      mensaje = 'Error al iniciar sesión: ${e.toString()}';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    cargando = true;
    notifyListeners();

    try {
      await _authService.signOut();
      usuario = null;
      mensaje = 'Sesión cerrada';
    } catch (e) {
      mensaje = 'Error al cerrar sesión: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}

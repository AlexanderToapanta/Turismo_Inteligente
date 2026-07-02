import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UsuarioService _usuarioService = UsuarioService();

  User? usuario;
  UsuarioModel? usuarioModel;
  bool cargando = false;
  String mensaje = '';
  // Error específico del flujo de registro (usado en RegisterView)
  String errorRegistro = '';

  AuthViewModel() {
    usuario = _authService.currentUser;
    if (usuario != null) {
      _cargarUsuarioModel(usuario!.uid);
    }
    _authService.authStateChanges.listen((User? user) {
      usuario = user;
      if (user != null) {
        _cargarUsuarioModel(user.uid);
      } else {
        usuarioModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _cargarUsuarioModel(String uid) async {
    usuarioModel = await _usuarioService.obtenerUsuario(uid);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  /// Limpia el mensaje y el error de registro anteriores.
  // ─────────────────────────────────────────────────────────
  void limpiarMensaje() {
    mensaje = '';
    errorRegistro = '';
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  /// Registro con correo, contraseña y nombre.
  /// Crea la cuenta en Auth y el documento en Firestore.
  // ─────────────────────────────────────────────────────────
  Future<void> registrarConCorreo({
    required String nombre,
    required String email,
    required String password,
  }) async {
    if (nombre.trim().isEmpty || email.isEmpty || password.isEmpty) {
      mensaje = 'Por favor completa todos los campos';
      notifyListeners();
      return;
    }

    cargando = true;
    mensaje = '';
    notifyListeners();

    try {
      usuario = await _authService.registrarConCorreo(
        nombre: nombre,
        email: email,
        password: password,
      );

      if (usuario != null) {
        await _cargarUsuarioModel(usuario!.uid);
        mensaje = 'Cuenta creada correctamente';
      }
    } catch (e) {
      errorRegistro = _mensajeFirebase(e);
      mensaje = errorRegistro;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  /// Inicio de sesión con Google.
  /// Crea el documento en Firestore si es la primera vez.
  // ─────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    errorRegistro = '';
    cargando = true;
    mensaje = '';
    notifyListeners();

    try {
      usuario = await _authService.signInWithGoogle();

      if (usuario != null) {
        await _cargarUsuarioModel(usuario!.uid);
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

  // ─────────────────────────────────────────────────────────
  /// Inicio de sesión con correo y contraseña.
  // ─────────────────────────────────────────────────────────
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
        await _cargarUsuarioModel(usuario!.uid);
        mensaje = 'Sesión iniciada correctamente';
      }
    } catch (e) {
      mensaje = 'Error al iniciar sesión: ${e.toString()}';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────
  /// Actualiza los datos del usuario actual (nombre y opcionalmente contraseña).
  // ─────────────────────────────────────────────────────────
  Future<String?> actualizarPerfil({
    required String nuevoNombre,
    String? nuevaPassword,
  }) async {
    cargando = true;
    notifyListeners();

    try {
      if (nuevoNombre.trim().isNotEmpty && nuevoNombre != usuarioModel?.nombre) {
        await _authService.actualizarNombre(nuevoNombre.trim());
      }
      if (nuevaPassword != null && nuevaPassword.isNotEmpty) {
        await _authService.actualizarPassword(nuevaPassword);
      }
      
      if (usuario != null) {
        await _cargarUsuarioModel(usuario!.uid);
      }
      
      return null; // Éxito
    } catch (e) {
      return _mensajeFirebase(e);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  /// Traduce los errores de FirebaseAuth a mensajes legibles en español.
  // ─────────────────────────────────────────────────────────
  String _mensajeFirebase(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Ya existe una cuenta con ese correo electrónico.';
        case 'invalid-email':
          return 'El formato del correo no es válido.';
        case 'weak-password':
          return 'La contraseña debe tener al menos 6 caracteres.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'user-not-found':
          return 'No existe una cuenta con ese correo.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde.';
        case 'network-request-failed':
          return 'Sin conexión a internet. Verifica tu red.';
        case 'operation-not-allowed':
          return 'Este método de autenticación no está habilitado.';
        default:
          return e.message ?? 'Ocurrió un error inesperado.';
      }
    }
    return e.toString();
  }
}

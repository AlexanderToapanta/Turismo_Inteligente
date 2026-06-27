import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/resena_model.dart';
import '../models/sitio_turistico.dart';
import '../services/resena_service.dart';
import '../services/usuario_service.dart';

class ResenaViewModel extends ChangeNotifier {
  final ResenaService _resenaService = ResenaService();
  final UsuarioService _usuarioService = UsuarioService();

  // ── Estado de la lista ───────────────────────────────────
  List<ResenaModel> _resenas = [];
  List<ResenaModel> get resenas => List.unmodifiable(_resenas);

  bool _cargando = false;
  bool get cargando => _cargando;

  String? _error;
  String? get error => _error;

  // ── Estado del formulario ────────────────────────────────
  // Los lugares vienen de TurismoViewModel (OpenStreetMap), no de Firestore
  SitioTuristico? _lugarSeleccionado;
  SitioTuristico? get lugarSeleccionado => _lugarSeleccionado;

  int _calificacion = 0;
  int get calificacion => _calificacion;

  File? _imagenSeleccionada;
  File? get imagenSeleccionada => _imagenSeleccionada;

  bool _publicando = false;
  bool get publicando => _publicando;

  // ─────────────────────────────────────────────────────────
  // Inicialización: solo carga reseñas (los lugares vienen del TurismoViewModel)
  // ─────────────────────────────────────────────────────────
  ResenaViewModel() {
    cargarResenas();
  }

  // ─────────────────────────────────────────────────────────
  /// Carga todas las reseñas desde Firestore.
  // ─────────────────────────────────────────────────────────
  Future<void> cargarResenas() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _resenas = await _resenaService.obtenerResenas();
    } catch (e) {
      _error = 'Error al cargar reseñas: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // Setters del formulario
  // ─────────────────────────────────────────────────────────
  void seleccionarLugar(SitioTuristico sitio) {
    _lugarSeleccionado = sitio;
    notifyListeners();
  }

  void setCalificacion(int valor) {
    _calificacion = valor;
    notifyListeners();
  }

  void setImagen(File imagen) {
    _imagenSeleccionada = imagen;
    notifyListeners();
  }

  void limpiarImagen() {
    _imagenSeleccionada = null;
    notifyListeners();
  }

  void resetFormulario() {
    _lugarSeleccionado = null;
    _calificacion = 0;
    _imagenSeleccionada = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  /// Publica una reseña.
  ///
  /// Retorna null si se publicó correctamente, o un mensaje
  /// de error de validación / excepción para mostrarlo en la UI.
  // ─────────────────────────────────────────────────────────
  Future<String?> publicarResena({
    required String titulo,
    required String comentario,
  }) async {
    // ── Validaciones ─────────────────────────────────────
    if (titulo.trim().isEmpty) return 'El título no puede estar vacío.';
    if (_lugarSeleccionado == null) return 'Selecciona un lugar turístico.';
    if (_calificacion < 1 || _calificacion > 5) {
      return 'La calificación debe estar entre 1 y 5 estrellas.';
    }
    if (comentario.trim().isEmpty) return 'El comentario no puede estar vacío.';

    // ── Obtener usuario autenticado ───────────────────────
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return 'No hay sesión activa.';

    _publicando = true;
    notifyListeners();

    try {
      // Obtener el nombre del usuario desde Firestore
      final usuarioDoc =
          await _usuarioService.obtenerUsuario(firebaseUser.uid);

      final nombreUsuario = usuarioDoc?.nombre ??
          firebaseUser.displayName ??
          'Usuario';

      // Publicar la reseña
      // Usamos el nombre como ID ya que SitioTuristico no tiene ID de Firestore
      final idLugar = _lugarSeleccionado!.nombre
          .toLowerCase()
          .replaceAll(' ', '_');
      await _resenaService.crearResena(
        idUsuario: firebaseUser.uid,
        nombreUsuario: nombreUsuario,
        idLugar: idLugar,
        nombreLugar: _lugarSeleccionado!.nombre,
        titulo: titulo.trim(),
        comentario: comentario.trim(),
        calificacion: _calificacion,
        imagenFile: _imagenSeleccionada,
      );

      // Actualizar la lista de reseñas
      await cargarResenas();

      // Limpiar el formulario
      resetFormulario();

      return null; // éxito
    } catch (e) {
      return 'Error al publicar la reseña: $e';
    } finally {
      _publicando = false;
      notifyListeners();
    }
  }
}

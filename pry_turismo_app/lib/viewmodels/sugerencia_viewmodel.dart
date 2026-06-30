import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/sugerencia_model.dart';
import '../services/sugerencia_service.dart';
import '../services/cloudinary_service.dart';

class SugerenciaViewModel extends ChangeNotifier {
  final SugerenciaService _sugerenciaService = SugerenciaService();
  final CloudinaryService _cloudinary = CloudinaryService();

  // ── Estado del formulario ────────────────────────────────
  File? _imagenSeleccionada;
  File? get imagenSeleccionada => _imagenSeleccionada;

  double? _latitud;
  double? get latitud => _latitud;

  double? _longitud;
  double? get longitud => _longitud;

  bool _cargandoUbicacion = false;
  bool get cargandoUbicacion => _cargandoUbicacion;

  bool _enviando = false;
  bool get enviando => _enviando;

  // ── Estado de la lista (Administrador) ──────────────────
  List<SugerenciaModel> _peticiones = [];
  List<SugerenciaModel> get peticiones => List.unmodifiable(_peticiones);

  bool _cargandoPeticiones = false;
  bool get cargandoPeticiones => _cargandoPeticiones;

  String? _errorPeticiones;
  String? get errorPeticiones => _errorPeticiones;

  // ── Estado de la lista (Usuario) ───────────────────────
  List<SugerenciaModel> _misSugerencias = [];
  List<SugerenciaModel> get misSugerencias => List.unmodifiable(_misSugerencias);

  bool _cargandoMisSugerencias = false;
  bool get cargandoMisSugerencias => _cargandoMisSugerencias;

  String? _errorMisSugerencias;
  String? get errorMisSugerencias => _errorMisSugerencias;

  // ─────────────────────────────────────────────────────────
  // Setters
  // ─────────────────────────────────────────────────────────
  void setImagen(File imagen) {
    _imagenSeleccionada = imagen;
    notifyListeners();
  }

  void limpiarImagen() {
    _imagenSeleccionada = null;
    notifyListeners();
  }

  Future<void> obtenerUbicacion() async {
    _cargandoUbicacion = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Los servicios de ubicación están deshabilitados.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Los permisos de ubicación fueron denegados.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Los permisos de ubicación están denegados permanentemente.';
      }

      // Intentamos obtener la posición con alta precisión
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      _latitud = position.latitude;
      _longitud = position.longitude;
    } catch (e) {
      // Intentar obtener la última ubicación conocida como respaldo
      try {
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          _latitud = lastPosition.latitude;
          _longitud = lastPosition.longitude;
        }
      } catch (_) {}
    } finally {
      _cargandoUbicacion = false;
      notifyListeners();
    }
  }

  void resetFormulario() {
    _imagenSeleccionada = null;
    _latitud = null;
    _longitud = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // Enviar sugerencia
  // ─────────────────────────────────────────────────────────
  Future<String?> enviarSugerencia({
    required String usuarioId,
    required String nombreUsuario,
    required String correoUsuario,
    required String nombreLugar,
    required String tipoLugar,
    required String horarioAtencion,
  }) async {
    if (nombreLugar.trim().isEmpty) return 'El nombre del lugar es requerido.';
    if (_latitud == null || _longitud == null) return 'La ubicación es requerida.';
    if (horarioAtencion.trim().isEmpty) return 'El horario es requerido.';

    _enviando = true;
    notifyListeners();

    try {
      String? fotoUrl;
      if (_imagenSeleccionada != null) {
        fotoUrl = await _cloudinary.uploadImage(_imagenSeleccionada!);
      }

      final sugerencia = SugerenciaModel(
        id: '', // Se asignará en Firestore
        usuarioId: usuarioId,
        nombreUsuario: nombreUsuario,
        correoUsuario: correoUsuario,
        nombreLugar: nombreLugar,
        tipoLugar: tipoLugar,
        latitud: _latitud!,
        longitud: _longitud!,
        horarioAtencion: horarioAtencion,
        fotoUrl: fotoUrl,
        estado: 'pendiente',
        fecha: DateTime.now(),
      );

      await _sugerenciaService.agregarSugerencia(sugerencia);
      resetFormulario();
      return null; // Éxito
    } catch (e) {
      return 'Error al enviar la sugerencia: $e';
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // Gestión de Peticiones (Administrador)
  // ─────────────────────────────────────────────────────────
  Future<void> cargarTodasLasPeticiones() async {
    _cargandoPeticiones = true;
    _errorPeticiones = null;
    notifyListeners();

    try {
      // Usamos el stream pero lo convertimos a un valor único para el "refresco" manual
      // o simplemente escuchamos el primer valor emitido.
      // Para consistencia con ResenasView, obtendremos los datos una vez.
      final snapshot = await _sugerenciaService.obtenerTodasLasSugerencias().first;
      _peticiones = snapshot;
    } catch (e) {
      _errorPeticiones = 'Error al cargar las peticiones: $e';
    } finally {
      _cargandoPeticiones = false;
      notifyListeners();
    }
  }

  Future<void> actualizarEstadoPeticion(String id, String nuevoEstado) async {
    try {
      await _sugerenciaService.actualizarEstado(id, nuevoEstado);
      // Recargamos la lista localmente
      await cargarTodasLasPeticiones();
    } catch (e) {
      _errorPeticiones = 'Error al actualizar el estado: $e';
      notifyListeners();
    }
  }

  Future<void> cargarMisSugerencias(String usuarioId) async {
    _cargandoMisSugerencias = true;
    _errorMisSugerencias = null;
    notifyListeners();

    try {
      final snapshot = await _sugerenciaService.obtenerSugerenciasUsuario(usuarioId).first;
      _misSugerencias = snapshot;
    } catch (e) {
      _errorMisSugerencias = 'Error al cargar tus sugerencias: $e';
    } finally {
      _cargandoMisSugerencias = false;
      notifyListeners();
    }
  }
}

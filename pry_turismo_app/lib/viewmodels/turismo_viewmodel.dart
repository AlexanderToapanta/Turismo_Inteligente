import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import '../models/sitio_turistico.dart';
import '../models/detalle_lugar.dart';
import '../services/turismo_service.dart';
import '../services/ruta_service.dart';
import '../services/google_places_service.dart';

class TurismoViewModel extends ChangeNotifier {
  final TurismoService _service = TurismoService();
  final RutaService _rutaService = RutaService();
  final GooglePlacesService _placesService = GooglePlacesService();

  Position? _posicionActual;
  List<SitioTuristico> _sitiosCercanos = [];
  double? _rumbo;
  bool _cargando = false;
  bool _cargandoLugares = false;
  String? _error;
  
  // Lista de puntos para la ruta (Polyline)
  List<LatLng> _puntosRuta = [];
  SitioTuristico? _sitioSeleccionado;

  // Detalles de Google Places
  bool _cargandoDetalles = false;
  DetalleLugar? _detalleActual;

  String _categoriaSeleccionada = 'Todos';
  final List<String> categorias = ['Todos', 'Hoteles', 'Comida', 'Cultura', 'Naturaleza'];

  // Para la brújula: azimut hacia el sitio seleccionado
  double? _azimutHaciaSitio;

  Position? get posicionActual => _posicionActual;
  List<SitioTuristico> get sitiosCercanos => _sitiosCercanos;
  double? get rumbo => _rumbo;
  bool get cargando => _cargando;
  bool get cargandoLugares => _cargandoLugares;
  bool get cargandoDetalles => _cargandoDetalles;
  String? get error => _error;
  List<LatLng> get puntosRuta => _puntosRuta;
  SitioTuristico? get sitioSeleccionado => _sitioSeleccionado;
  DetalleLugar? get detalleActual => _detalleActual;
  double? get azimutHaciaSitio => _azimutHaciaSitio;
  String get categoriaSeleccionada => _categoriaSeleccionada;
  
  // Acceso al servicio para formatear imágenes
  GooglePlacesService get placesService => _placesService;

  List<SitioTuristico> get sitiosFiltrados {
    if (_categoriaSeleccionada == 'Todos') {
      return _sitiosCercanos;
    }
    return _sitiosCercanos
        .where((sitio) => sitio.categoria == _categoriaSeleccionada)
        .toList();
  }

  void cambiarCategoria(String nuevaCategoria) {
    if (categorias.contains(nuevaCategoria)) {
      _categoriaSeleccionada = nuevaCategoria;
      notifyListeners();
    }
  }

  TurismoViewModel() {
    inicializar();
  }

  Future<void> inicializar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _posicionActual = await _service.obtenerUbicacionActual();
      await _cargarLugaresCercanos();
      
      // Escuchar cambios en la brújula
      FlutterCompass.events?.listen((event) {
        _rumbo = event.heading;
        notifyListeners();
      });

      // Escuchar cambios de posición
      Geolocator.getPositionStream().listen((Position position) {
        _posicionActual = position;
        _cargarLugaresCercanos();
        _actualizarAzimutHaciaSitio();
        notifyListeners();
      });

    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Carga los lugares cercanos en tiempo real desde OpenStreetMap
  Future<void> _cargarLugaresCercanos() async {
    if (_posicionActual == null) return;
    
    _cargandoLugares = true;
    notifyListeners();

    try {
      _sitiosCercanos = await _service.obtenerLugaresCercanosEnTiempoReal(
        _posicionActual!.latitude,
        _posicionActual!.longitude,
      );
      
      if (_sitiosCercanos.isEmpty) {
        _error = "No hay lugares turísticos cercanos en este momento.";
      }
    } catch (e) {
      _error = "Error al cargar lugares: $e";
    } finally {
      _cargandoLugares = false;
      notifyListeners();
    }
  }

  /// Actualiza el azimut hacia el sitio seleccionado
  void _actualizarAzimutHaciaSitio() {
    if (_posicionActual != null && _sitioSeleccionado != null) {
      _azimutHaciaSitio = _service.calcularAzimut(
        _posicionActual!.latitude,
        _posicionActual!.longitude,
        _sitioSeleccionado!.latitud,
        _sitioSeleccionado!.longitud,
      );
    }
  }

  // Trazar ruta hacia un sitio específico
  Future<void> trazarRuta(SitioTuristico sitio) async {
    if (_posicionActual == null) return;
    
    _cargando = true;
    _sitioSeleccionado = sitio;
    _puntosRuta = [];
    _actualizarAzimutHaciaSitio();
    notifyListeners();

    try {
      final inicio = LatLng(_posicionActual!.latitude, _posicionActual!.longitude);
      final destino = LatLng(sitio.latitud, sitio.longitud);
      
      _puntosRuta = await _rutaService.obtenerPuntosRuta(inicio, destino);
      
      if (_puntosRuta.isEmpty) {
        _error = "No se pudo encontrar una ruta.";
      }
    } catch (e) {
      _error = "Error al trazar la ruta: $e";
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiarRuta() {
    _puntosRuta = [];
    _sitioSeleccionado = null;
    _azimutHaciaSitio = null;
    notifyListeners();
  }

  /// Carga los detalles desde Google Places
  Future<void> cargarDetallesLugar(SitioTuristico sitio) async {
    _cargandoDetalles = true;
    _detalleActual = null;
    notifyListeners();

    try {
      // 1. Buscar el place_id
      final placeId = await _placesService.buscarLugarId(
        sitio.nombre, 
        sitio.latitud, 
        sitio.longitud
      );

      if (placeId != null) {
        // 2. Obtener los detalles
        _detalleActual = await _placesService.obtenerDetalles(placeId);
      }
    } catch (e) {
      print('Error al cargar detalles: $e');
    } finally {
      _cargandoDetalles = false;
      notifyListeners();
    }
  }

  double obtenerDistancia(SitioTuristico sitio) {
    if (_posicionActual == null) return 0;
    return _service.calcularDistancia(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
      sitio.latitud,
      sitio.longitud,
    );
  }

  /// Obtiene el azimut hacia un sitio específico
  double obtenerAzimutHaciaSitio(SitioTuristico sitio) {
    if (_posicionActual == null) return 0;
    return _service.calcularAzimut(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
      sitio.latitud,
      sitio.longitud,
    );
  }

  /// Obtiene la dirección cardinal hacia un sitio (N, NE, E, SE, S, SW, W, NW)
  String obtenerDireccionCardinal(SitioTuristico sitio) {
    double azimut = obtenerAzimutHaciaSitio(sitio);
    return _service.azimutADireccionCardinal(azimut);
  }

  String formatearDistancia(double metros) {
    if (metros < 1000) {
      return "${metros.toStringAsFixed(0)} m";
    } else {
      return "${(metros / 1000).toStringAsFixed(2)} km";
    }
  }

  /// Obtiene la dirección cardinal desde el rumbo actual y el azimut hacia el sitio
  String obtenerDireccionRelativa(SitioTuristico sitio) {
    double azimut = obtenerAzimutHaciaSitio(sitio);
    return _service.azimutADireccionCardinal(azimut);
  }
}

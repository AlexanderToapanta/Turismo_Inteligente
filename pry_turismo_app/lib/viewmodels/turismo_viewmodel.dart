import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import '../models/sitio_turistico.dart';
import '../models/detalle_lugar.dart';
import '../services/turismo_service.dart';
import '../services/ruta_service.dart';
import '../services/google_places_service.dart';
import '../services/resena_service.dart';
import '../services/sugerencia_service.dart';

class TurismoViewModel extends ChangeNotifier {
  final TurismoService _service = TurismoService();
  final RutaService _rutaService = RutaService();
  final GooglePlacesService _placesService = GooglePlacesService();
  final ResenaService _resenaService = ResenaService();
  final SugerenciaService _sugerenciaService = SugerenciaService();

  Position? _posicionActual;
  List<SitioTuristico> _sitiosCercanos = [];
  List<SitioTuristico> _sugerenciasAprobadas = [];
  double? _rumbo;
  bool _cargando = false;
  bool _cargandoLugares = false;
  String? _error;
  Position? _ultimaPosicionCarga;
  final Map<String, double> _distanciasReales = {};
  
  // Lista de puntos para la ruta (Polyline)
  List<LatLng> _puntosRuta = [];
  SitioTuristico? _sitioSeleccionado;

  // Detalles de Google Places
  bool _cargandoDetalles = false;
  DetalleLugar? _detalleActual;

  // Promedio de reseñas de la app
  Map<String, dynamic>? _promedioResenas;
  bool _cargandoPromedio = false;

  String _categoriaSeleccionada = 'Todos';
  final List<String> categorias = ['Todos', 'Hoteles', 'Comida', 'Cultura', 'Naturaleza'];

  // Para la brújula: azimut hacia el sitio seleccionado
  double? _azimutHaciaSitio;

  Position? get posicionActual => _posicionActual;
  // Lista combinada: OSM + sugerencias aprobadas de Firebase
  List<SitioTuristico> get sitiosCercanos {
    final nombres = _sitiosCercanos.map((s) => s.nombre.toLowerCase()).toSet();
    final extras = _sugerenciasAprobadas
        .where((s) => !nombres.contains(s.nombre.toLowerCase()))
        .toList();
    return [..._sitiosCercanos, ...extras];
  }
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
  Map<String, dynamic>? get promedioResenas => _promedioResenas;
  bool get cargandoPromedio => _cargandoPromedio;
  
  // Acceso al servicio para formatear imágenes
  GooglePlacesService get placesService => _placesService;

  List<SitioTuristico> get sitiosFiltrados {
    final todos = sitiosCercanos;
    if (_categoriaSeleccionada == 'Todos') return todos;
    return todos.where((s) => s.categoria == _categoriaSeleccionada).toList();
  }

  void cambiarCategoria(String nuevaCategoria) {
    if (categorias.contains(nuevaCategoria)) {
      _categoriaSeleccionada = nuevaCategoria;
      notifyListeners();
    }
  }

  TurismoViewModel() {
    inicializar();
    // Suscribirse a las sugerencias aprobadas de Firebase en tiempo real
    _sugerenciaService.obtenerSugerenciasAprobadasComoSitios().listen((lista) {
      _sugerenciasAprobadas = lista;
      notifyListeners();
    });
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
        
        // Solo recargar si no tenemos posición previa o nos hemos movido más de 500 metros
        if (_ultimaPosicionCarga == null || 
            Geolocator.distanceBetween(
              _ultimaPosicionCarga!.latitude, 
              _ultimaPosicionCarga!.longitude, 
              position.latitude, 
              position.longitude
            ) > 500) {
          _ultimaPosicionCarga = position;
          _cargarLugaresCercanos();
        }
        
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
      final nuevosSitios = await _service.obtenerLugaresCercanosEnTiempoReal(
        _posicionActual!.latitude,
        _posicionActual!.longitude,
      );
      
      _sitiosCercanos = nuevosSitios;
      
      if (_sitiosCercanos.isEmpty) {
        _error = "No hay lugares turísticos cercanos en este momento.";
      } else {
        _error = null;
        _calcularDistanciasReales();
      }
    } catch (e) {
      // Si hay error, no borramos los lugares que ya teníamos
      _error = "Error al cargar lugares: $e";
      print(_error);
    } finally {
      _cargandoLugares = false;
      notifyListeners();
    }
  }

  Future<void> _calcularDistanciasReales() async {
    if (_posicionActual == null || _sitiosCercanos.isEmpty) return;

    final inicio = LatLng(_posicionActual!.latitude, _posicionActual!.longitude);
    final destinos = _sitiosCercanos.map((s) => LatLng(s.latitud, s.longitud)).toList();

    try {
      final distancias = await _rutaService.obtenerDistanciasMatrix(inicio, destinos);
      if (distancias.length == destinos.length) {
        for (int i = 0; i < destinos.length; i++) {
          _distanciasReales[_sitiosCercanos[i].nombre] = distancias[i];
        }
        notifyListeners();
      }
    } catch (e) {
      print("Error obteniendo distancias reales: $e");
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

  /// Carga los detalles desde Google Places y el promedio de reseñas de la app
  Future<void> cargarDetallesLugar(SitioTuristico sitio) async {
    _cargandoDetalles = true;
    _cargandoPromedio = true;
    _detalleActual = null;
    _promedioResenas = null;
    notifyListeners();

    final idLugar = sitio.nombre.toLowerCase().replaceAll(' ', '_');

    if (sitio.esSugerencia) {
      // Para sugerencias comunitarias: solo cargar promedio de reseñas de la app
      try {
        _promedioResenas = await _resenaService.obtenerPromedioResenas(idLugar);
      } catch (e) {
        print('Error al cargar promedio de reseñas: $e');
      } finally {
        _cargandoDetalles = false;
        _cargandoPromedio = false;
      }
      notifyListeners();
      return;
    }

    // Para lugares de OpenStreetMap: cargar Google Places + promedio en paralelo
    await Future.wait([
      () async {
        try {
          final placeId = await _placesService.buscarLugarId(
            sitio.nombre,
            sitio.latitud,
            sitio.longitud,
          );
          if (placeId != null) {
            _detalleActual = await _placesService.obtenerDetalles(placeId);
          }
        } catch (e) {
          print('Error al cargar detalles de Places: $e');
        } finally {
          _cargandoDetalles = false;
        }
      }(),
      () async {
        try {
          _promedioResenas =
              await _resenaService.obtenerPromedioResenas(idLugar);
        } catch (e) {
          print('Error al cargar promedio de reseñas: $e');
        } finally {
          _cargandoPromedio = false;
        }
      }(),
    ]);

    notifyListeners();
  }

  double obtenerDistancia(SitioTuristico sitio) {
    if (_posicionActual == null) return 0;
    
    // Si tenemos la distancia real por ruta, la usamos
    if (_distanciasReales.containsKey(sitio.nombre)) {
      return _distanciasReales[sitio.nombre]!;
    }
    
    // Fallback a distancia en línea recta (Haversine)
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

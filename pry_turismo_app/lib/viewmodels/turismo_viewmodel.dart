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
  
  List<LatLng> _puntosRuta = [];
  SitioTuristico? _sitioSeleccionado;
  bool _cargandoDetalles = false;
  DetalleLugar? _detalleActual;
  Map<String, dynamic>? _promedioResenas;
  bool _cargandoPromedio = false;

  String _busqueda = '';
  String get busqueda => _busqueda;

  String _categoriaSeleccionada = 'Todos';
  final List<String> categorias = ['Todos', 'Hoteles', 'Comida', 'Cultura', 'Naturaleza'];
  double? _azimutHaciaSitio;

  Position? get posicionActual => _posicionActual;

  List<SitioTuristico> get sitiosCercanos {
    if (_posicionActual == null) return [];

    final nombres = _sitiosCercanos.map((s) => s.nombre.toLowerCase()).toSet();
    
    // Filtrar sugerencias por distancia (5 km) y evitar duplicados
    final extras = _sugerenciasAprobadas.where((s) {
      final dist = _service.calcularDistancia(
        _posicionActual!.latitude,
        _posicionActual!.longitude,
        s.latitud,
        s.longitud,
      );
      
      return dist <= TurismoService.DISTANCIA_MAXIMA && !nombres.contains(s.nombre.toLowerCase());
    }).toList();

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

  GooglePlacesService get placesService => _placesService;

  List<SitioTuristico> get sitiosFiltrados {
    var lista = sitiosCercanos;
    
    // Filtro por categoría
    if (_categoriaSeleccionada != 'Todos') {
      lista = lista.where((s) => s.categoria == _categoriaSeleccionada).toList();
    }

    // Filtro por búsqueda de texto
    if (_busqueda.isNotEmpty) {
      lista = lista.where((s) => 
        s.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
        s.descripcion.toLowerCase().contains(_busqueda.toLowerCase())
      ).toList();
    }

    return lista;
  }

  void buscarSitio(String query) {
    _busqueda = query;
    notifyListeners();
  }

  void cambiarCategoria(String nuevaCategoria) {
    if (categorias.contains(nuevaCategoria)) {
      _categoriaSeleccionada = nuevaCategoria;
      notifyListeners();
    }
  }

  /// Método público para refrescar manualmente los lugares desde la UI
  Future<void> refrescarLugares() async {
    await _cargarLugaresCercanos();
    // No hace falta llamar a _calcularDistanciasReales() porque ya se llama dentro de _cargarLugaresCercanos()
  }

  TurismoViewModel() {
    inicializar();
    _sugerenciaService.obtenerSugerenciasAprobadasComoSitios().listen((lista) {
      _sugerenciasAprobadas = lista;
      _calcularDistanciasReales();
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
      
      FlutterCompass.events?.listen((event) {
        _rumbo = event.heading;
        notifyListeners();
      });

      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        _posicionActual = position;
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
        _error = "No hay lugares turísticos cercanos.";
      } else {
        _error = null;
        _calcularDistanciasReales();
      }
    } catch (e) {
      _error = "Error al cargar lugares: $e";
    } finally {
      _cargandoLugares = false;
      notifyListeners();
    }
  }

  Future<void> _calcularDistanciasReales() async {
    if (_posicionActual == null) return;
    
    final todos = sitiosCercanos;
    if (todos.isEmpty) return;

    final inicio = LatLng(_posicionActual!.latitude, _posicionActual!.longitude);
    final destinos = todos.map((s) => LatLng(s.latitud, s.longitud)).toList();

    try {
      final distancias = await _rutaService.obtenerDistanciasMatrix(inicio, destinos);
      if (distancias.length == destinos.length) {
        for (int i = 0; i < destinos.length; i++) {
          final s = todos[i];
          final key = "${s.nombre}_${s.latitud}_${s.longitud}";
          _distanciasReales[key] = distancias[i];
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error obteniendo distancias reales: $e");
    }
  }

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

  Future<void> cargarDetallesLugar(SitioTuristico sitio) async {
    _cargandoDetalles = true;
    _cargandoPromedio = true;
    _detalleActual = null;
    _promedioResenas = null;
    notifyListeners();

    final idLugar = sitio.nombre.toLowerCase().replaceAll(' ', '_');

    if (sitio.esSugerencia) {
      try {
        _promedioResenas = await _resenaService.obtenerPromedioResenas(idLugar);
      } catch (e) {
        debugPrint('Error al cargar promedio de reseñas: $e');
      } finally {
        _cargandoDetalles = false;
        _cargandoPromedio = false;
      }
      notifyListeners();
      return;
    }

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
          debugPrint('Error al cargar detalles de Places: $e');
        } finally {
          _cargandoDetalles = false;
        }
      }(),
      () async {
        try {
          _promedioResenas = await _resenaService.obtenerPromedioResenas(idLugar);
        } catch (e) {
          debugPrint('Error al cargar promedio de reseñas: $e');
        } finally {
          _cargandoPromedio = false;
        }
      }(),
    ]);
    notifyListeners();
  }

  double obtenerDistancia(SitioTuristico sitio) {
    if (_posicionActual == null) return 0;
    final key = "${sitio.nombre}_${sitio.latitud}_${sitio.longitud}";
    if (_distanciasReales.containsKey(key)) {
      return _distanciasReales[key]!;
    }
    return _service.calcularDistancia(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
      sitio.latitud,
      sitio.longitud,
    );
  }

  double obtenerAzimutHaciaSitio(SitioTuristico sitio) {
    if (_posicionActual == null) return 0;
    return _service.calcularAzimut(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
      sitio.latitud,
      sitio.longitud,
    );
  }

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

  String obtenerDireccionRelativa(SitioTuristico sitio) {
    double azimut = obtenerAzimutHaciaSitio(sitio);
    return _service.azimutADireccionCardinal(azimut);
  }
}

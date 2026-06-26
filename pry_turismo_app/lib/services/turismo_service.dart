import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../models/sitio_turistico.dart';
import 'lugares_reales_service.dart';

class TurismoService {
  // Distancia máxima en metros para considerar un sitio como "cercano"
  static const double DISTANCIA_MAXIMA = 10000; // 10 km
  
  final LugaresRealesService _lugaresService = LugaresRealesService();

  /// Obtiene lugares cercanos en tiempo real desde OpenStreetMap
  Future<List<SitioTuristico>> obtenerLugaresCercanosEnTiempoReal(
    double latitud,
    double longitud,
  ) async {
    try {
      final lugares = await _lugaresService.obtenerLugaresCercanos(
        latitud,
        longitud,
        radio: DISTANCIA_MAXIMA,
      );
      return lugares;
    } catch (e) {
      print('Error obteniendo lugares en tiempo real: $e');
      return [];
    }
  }

  double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Calcula el azimut (bearing) entre dos puntos en grados (0-360)
  /// 0° = Norte, 90° = Este, 180° = Sur, 270° = Oeste
  double calcularAzimut(double lat1, double lon1, double lat2, double lon2) {
    double dLon = (lon2 - lon1);
    double y = math.sin(dLon * math.pi / 180) * math.cos(lat2 * math.pi / 180);
    double x = math.cos(lat1 * math.pi / 180) * math.sin(lat2 * math.pi / 180) -
        math.sin(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) * math.cos(dLon * math.pi / 180);
    double azimut = (math.atan2(y, x) * 180 / math.pi + 360) % 360;
    return azimut;
  }

  /// Convierte un azimut (0-360) a dirección cardinal (N, NE, E, SE, S, SW, W, NW)
  String azimutADireccionCardinal(double azimut) {
    if (azimut >= 337.5 || azimut < 22.5) return "N";
    if (azimut >= 22.5 && azimut < 67.5) return "NE";
    if (azimut >= 67.5 && azimut < 112.5) return "E";
    if (azimut >= 112.5 && azimut < 157.5) return "SE";
    if (azimut >= 157.5 && azimut < 202.5) return "S";
    if (azimut >= 202.5 && azimut < 247.5) return "SW";
    if (azimut >= 247.5 && azimut < 292.5) return "W";
    if (azimut >= 292.5 && azimut < 337.5) return "NW";
    return "N";
  }

  Future<Position> obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están desactivados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permisos de ubicación denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }
}

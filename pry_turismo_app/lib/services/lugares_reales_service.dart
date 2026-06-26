import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/sitio_turistico.dart';

/// Servicio para obtener sitios turísticos reales desde OpenStreetMap
class LugaresRealesService {
  // URL de búsqueda de Nominatim (más compatible con navegadores)
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  /// Obtiene sitios turísticos cercanos basados en latitud y longitud
  /// Utiliza Nominatim que es más web-friendly que Overpass
  /// NOTA: En navegador desktop, la geolocalización es imprecisa (por IP)
  /// En móvil, usa GPS nativo (mucho más preciso)
  Future<List<SitioTuristico>> obtenerLugaresCercanos(
    double latitud,
    double longitud, {
    double radio = 5000,
  }) async {
    print('=== OBTENER LUGARES CERCANOS ===');
    print('Latitud: $latitud, Longitud: $longitud');
    print('Radio: ${(radio / 1000).toStringAsFixed(1)} km');

    try {
      // Calcular bounding box en grados decimales
      // 1 grado ≈ 111 km en latitud
      final kmRadius = radio / 1000;
      final deltaLat = kmRadius / 111.0;
      final deltaLon = kmRadius / (111.0 * math.cos(latitud * math.pi / 180));

      final bbox = '${longitud - deltaLon},${latitud - deltaLat},${longitud + deltaLon},${latitud + deltaLat}';
      print('BBox: $bbox');

      final List<SitioTuristico> lugares = [];

      // Lista de búsquedas por categoría - varias queries para obtener diversidad
      final queries = [
        'tourist attraction',
        'museum',
        'park',
        'historic',
        'viewpoint',
        'artwork',
        'monument',
      ];

      for (String query in queries) {
        try {
          final response = await http.get(
            Uri.parse(_nominatimUrl).replace(
              queryParameters: {
                'q': query,
                'format': 'json',
                'viewbox': bbox,
                'bounded': '1', // Limitar a bbox
                'limit': '10',
                'accept-language': 'es',
              },
            ),
            headers: {
              'User-Agent': 'TurismoApp/1.0',
            },
          ).timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            final data = json.decode(response.body) as List;
            print('Query "$query": ${data.length} resultados');

            for (var item in data) {
              if (item['lat'] != null && item['lon'] != null) {
                final sitioLat = double.parse(item['lat'].toString());
                final sitioLon = double.parse(item['lon'].toString());

                // Validar que esté dentro del radio usando distancia Haversine
                final dist = _calcularDistancia(latitud, longitud, sitioLat, sitioLon);
                
                if (dist <= radio) {
                  lugares.add(
                    SitioTuristico(
                      nombre: (item['name'] ?? 'Lugar').toString(),
                      descripcion: (item['type'] ?? 'Lugar de interés').toString(),
                      latitud: sitioLat,
                      longitud: sitioLon,
                      imagenUrl: _obtenerIconoSegunTipo(item['type'] ?? ''),
                    ),
                  );
                  print('  ✅ ${item['name']} (${(dist / 1000).toStringAsFixed(2)} km)');
                } else {
                  print('  ❌ Rechazado: ${item['name']} (${(dist / 1000).toStringAsFixed(2)} km)');
                }
              }
            }
          }
        } catch (e) {
          print('⚠️ Error en búsqueda "$query": $e');
          continue;
        }
      }

      print('Total inicial: ${lugares.length}');

      // Eliminar duplicados y ordenar por distancia
      return _procesarElementos(lugares, latitud, longitud);
    } catch (e) {
      print('❌ Error obteniendo lugares reales: $e');
    }

    return [];
  }

  /// Procesa y limpia la lista de sitios
  List<SitioTuristico> _procesarElementos(
    List<SitioTuristico> lugares,
    double refLat,
    double refLon,
  ) {
    // Eliminar duplicados por nombre (case-insensitive)
    final Map<String, SitioTuristico> uniqueLugares = {};
    for (var sitio in lugares) {
      final clave = sitio.nombre.toLowerCase();
      if (!uniqueLugares.containsKey(clave)) {
        uniqueLugares[clave] = sitio;
      }
    }

    final List<SitioTuristico> listaNuevo = uniqueLugares.values.toList();

    // Ordenar por distancia desde la referencia
    listaNuevo.sort((a, b) {
      double distA = _calcularDistancia(refLat, refLon, a.latitud, a.longitud);
      double distB = _calcularDistancia(refLat, refLon, b.latitud, b.longitud);
      return distA.compareTo(distB);
    });

    print('Sitios encontrados (sin duplicados): ${listaNuevo.length}');

    return listaNuevo.take(20).toList(); // Limitar a 20 lugares
  }

  /// Obtiene un ícono/URL basado en el tipo de lugar (desde Nominatim)
  String _obtenerIconoSegunTipo(String tipo) {
    tipo = tipo.toLowerCase();

    if (tipo.contains('museum')) {
      return 'https://images.unsplash.com/photo-1503174971373-b1f69850bbd6?w=400&h=400&fit=crop';
    } else if (tipo.contains('park') || tipo.contains('garden')) {
      return 'https://images.unsplash.com/photo-1549144464-f6eb00924190?w=400&h=400&fit=crop';
    } else if (tipo.contains('monument') || tipo.contains('historic')) {
      return 'https://images.unsplash.com/photo-1518156677180-95a2893f3e9f?w=400&h=400&fit=crop';
    } else if (tipo.contains('viewpoint') || tipo.contains('view')) {
      return 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=400&h=400&fit=crop';
    } else if (tipo.contains('tourist') || tipo.contains('attraction')) {
      return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=400&fit=crop';
    } else {
      return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=400&fit=crop';
    }
  }

  /// Calcula distancia entre dos puntos usando la fórmula de Haversine
  double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Radio de la Tierra en metros
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLon = (lon2 - lon1) * math.pi / 180;
    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.pow(math.sin(dLon / 2), 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
}

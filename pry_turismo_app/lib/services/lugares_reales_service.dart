import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/sitio_turistico.dart';

/// Servicio para obtener sitios turísticos reales desde OpenStreetMap usando Overpass API.
class LugaresRealesService {
  static const List<String> _overpassUrls = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.ru/api/interpreter',
  ];

  Future<List<SitioTuristico>> obtenerLugaresCercanos(
    double latitud,
    double longitud, {
    double radio = 10000,
  }) async {
    print('=== BUSCANDO EN OVERPASS ===');
    print('Lat: $latitud, Lon: $longitud, Radio: $radio m');

    final query =
        '''
[out:json][timeout:25];

(
  node["amenity"~"restaurant|cafe|fast_food|bar"](around:$radio,$latitud,$longitud);
  way["amenity"~"restaurant|cafe|fast_food|bar"](around:$radio,$latitud,$longitud);

  node["tourism"~"hotel|hostel|guest_house|motel"](around:$radio,$latitud,$longitud);
  way["tourism"~"hotel|hostel|guest_house|motel"](around:$radio,$latitud,$longitud);

  node["tourism"~"museum|attraction|gallery"](around:$radio,$latitud,$longitud);
  way["tourism"~"museum|attraction|gallery"](around:$radio,$latitud,$longitud);

  node["historic"](around:$radio,$latitud,$longitud);
  way["historic"](around:$radio,$latitud,$longitud);

  node["amenity"="place_of_worship"](around:$radio,$latitud,$longitud);
  way["amenity"="place_of_worship"](around:$radio,$latitud,$longitud);

  node["leisure"~"park|nature_reserve"](around:$radio,$latitud,$longitud);
  way["leisure"~"park|nature_reserve"](around:$radio,$latitud,$longitud);

  node["natural"~"peak|water|wood|cave_entrance"](around:$radio,$latitud,$longitud);
  way["natural"~"peak|water|wood|cave_entrance"](around:$radio,$latitud,$longitud);

  node["tourism"="viewpoint"](around:$radio,$latitud,$longitud);
  way["tourism"="viewpoint"](around:$radio,$latitud,$longitud);
);

out center tags;
''';

    try {
      final response = await _consultarOverpass(query);

      if (response == null) {
        throw Exception('No se pudo conectar con ningún servidor Overpass.');
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Error Overpass final: ${response.statusCode} - ${response.body}',
        );
      }

      final data = json.decode(response.body);
      final elements = data['elements'] as List? ?? [];

      final List<SitioTuristico> lugares = [];

      for (final item in elements) {
        final tags = item['tags'] ?? {};

        final nombre = tags['name'];
        if (nombre == null || nombre.toString().trim().isEmpty) {
          continue;
        }

        final double? lat = item['lat'] != null
            ? double.tryParse(item['lat'].toString())
            : double.tryParse(item['center']?['lat']?.toString() ?? '');

        final double? lon = item['lon'] != null
            ? double.tryParse(item['lon'].toString())
            : double.tryParse(item['center']?['lon']?.toString() ?? '');

        if (lat == null || lon == null) continue;

        final distancia = _calcularDistancia(latitud, longitud, lat, lon);
        if (distancia > radio) continue;

        final categoria = _obtenerCategoria(tags);

        lugares.add(
          SitioTuristico(
            nombre: nombre.toString(),
            descripcion: _obtenerDescripcion(tags),
            latitud: lat,
            longitud: lon,
            imagenUrl: _obtenerIconoSegunCategoria(categoria),
            categoria: categoria,
          ),
        );
      }

      print('Lugares encontrados: ${lugares.length}');
      return _procesarElementos(lugares, latitud, longitud);
    } catch (e) {
      print('Error obteniendo lugares desde Overpass: $e');
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<http.Response?> _consultarOverpass(String query) async {
    for (final url in _overpassUrls) {
      try {
        print('Probando servidor Overpass: $url');

        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent': 'TurismoApp/1.0',
              },
              body: {'data': query},
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          print('Servidor Overpass funcionando: $url');
          return response;
        }

        print('Error Overpass en $url: ${response.statusCode}');
      } catch (e) {
        print('Fallo conexión Overpass en $url: $e');
      }
    }

    return null;
  }

  String _obtenerCategoria(Map tags) {
    final amenity = tags['amenity']?.toString();
    final tourism = tags['tourism']?.toString();
    final leisure = tags['leisure']?.toString();
    final natural = tags['natural']?.toString();
    final historic = tags['historic']?.toString();

    if (amenity == 'restaurant' ||
        amenity == 'cafe' ||
        amenity == 'fast_food' ||
        amenity == 'bar') {
      return 'Comida';
    }

    if (tourism == 'hotel' ||
        tourism == 'hostel' ||
        tourism == 'guest_house' ||
        tourism == 'motel') {
      return 'Hoteles';
    }

    if (historic != null ||
        tourism == 'museum' ||
        tourism == 'gallery' ||
        tourism == 'attraction' ||
        amenity == 'place_of_worship') {
      return 'Cultura';
    }

    if (leisure == 'park' ||
        leisure == 'nature_reserve' ||
        natural != null ||
        tourism == 'viewpoint') {
      return 'Naturaleza';
    }

    return 'Cultura';
  }

  String _obtenerDescripcion(Map tags) {
    if (tags['tourism'] != null) return 'Turismo: ${tags['tourism']}';
    if (tags['amenity'] != null) return 'Servicio: ${tags['amenity']}';
    if (tags['historic'] != null) return 'Histórico: ${tags['historic']}';
    if (tags['leisure'] != null) return 'Recreación: ${tags['leisure']}';
    if (tags['natural'] != null) return 'Natural: ${tags['natural']}';
    return 'Lugar de interés';
  }

  List<SitioTuristico> _procesarElementos(
    List<SitioTuristico> lugares,
    double refLat,
    double refLon,
  ) {
    final Map<String, SitioTuristico> unicos = {};

    for (final sitio in lugares) {
      final clave = sitio.nombre.toLowerCase().trim();
      unicos[clave] = sitio;
    }

    final lista = unicos.values.toList();

    lista.sort((a, b) {
      final distA = _calcularDistancia(refLat, refLon, a.latitud, a.longitud);
      final distB = _calcularDistancia(refLat, refLon, b.latitud, b.longitud);
      return distA.compareTo(distB);
    });

    return lista.take(50).toList();
  }

  String _obtenerIconoSegunCategoria(String categoria) {
    switch (categoria) {
      case 'Hoteles':
        return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=400&fit=crop';
      case 'Comida':
        return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400&h=400&fit=crop';
      case 'Cultura':
        return 'https://images.unsplash.com/photo-1518156677180-95a2893f3e9f?w=400&h=400&fit=crop';
      case 'Naturaleza':
        return 'https://images.unsplash.com/photo-1549144464-f6eb00924190?w=400&h=400&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=400&fit=crop';
    }
  }

  double _calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double r = 6371000;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.pow(math.sin(dLon / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }
}

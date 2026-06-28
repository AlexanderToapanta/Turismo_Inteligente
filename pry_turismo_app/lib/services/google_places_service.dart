import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/detalle_lugar.dart';

class GooglePlacesService {
  // ATENCIÓN: Por motivos de practicidad para esta implementación inicial,
  // usaremos la misma llave declarada en tu AndroidManifest.xml.
  // En un entorno de producción, DEBES proteger esta llave usándola desde un
  // backend propio o al menos cargándola desde un archivo .env con flutter_dotenv.
  static const String _apiKey = 'AIzaSyBsy3BVDbD1e-dYa9g_mdJMEyD7IXyuc-k';

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// Busca un lugar en Google Places usando su nombre y coordenadas cercanas
  /// Retorna el place_id si lo encuentra
  Future<String?> buscarLugarId(String nombre, double lat, double lng) async {
    final url =
        '$_baseUrl/textsearch/json?query=${Uri.encodeComponent(nombre)}&location=$lat,$lng&radius=10000&language=es&key=$_apiKey';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['results'] != null &&
            data['results'].isNotEmpty) {
          // Retornar el place_id del mejor resultado (el primero)
          return data['results'][0]['place_id'];
        } else {
          print(
            'Google Places API Error (Búsqueda): ${data['status']} - ${data['error_message'] ?? 'Sin mensaje de error'} (Query: $nombre)',
          );
        }
      } else {
        print('Error HTTP (Búsqueda): ${response.statusCode}');
      }
      return null; // No se encontró o hubo un status distinto de OK
    } catch (e) {
      print('Error Exception al buscar lugar en Google Places: $e');
      return null;
    }
  }

  /// Obtiene los detalles de un lugar usando su place_id
  Future<DetalleLugar?> obtenerDetalles(String placeId) async {
    final url =
        '$_baseUrl/details/json?place_id=$placeId&fields=rating,photos,opening_hours,formatted_phone_number,website,formatted_address&language=es&key=$_apiKey';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          return DetalleLugar.fromJson(data['result']);
        } else {
          print(
            'Google Places API Error (Detalles): ${data['status']} - ${data['error_message'] ?? 'Sin mensaje de error'}',
          );
        }
      } else {
        print('Error HTTP (Detalles): ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('Error Exception al obtener detalles en Google Places: $e');
      return null;
    }
  }

  /// Helper para construir la URL de una foto usando la referencia de Google
  String obtenerUrlFoto(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }
}

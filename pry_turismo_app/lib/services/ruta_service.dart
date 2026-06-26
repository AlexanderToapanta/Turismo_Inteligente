import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class RutaService {
  /// Obtiene los puntos de la ruta entre el inicio y el destino usando OSRM
  Future<List<LatLng>> obtenerPuntosRuta(LatLng inicio, LatLng destino) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${inicio.longitude},${inicio.latitude};${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] == null || data['routes'].isEmpty) return [];
        
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        
        // OSRM devuelve [longitud, latitud], invertimos para LatLng(lat, lng)
        return coordinates.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error en RutaService: $e');
      return [];
    }
  }
}

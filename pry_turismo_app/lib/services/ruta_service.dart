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

  /// Obtiene distancias de ruta desde un origen a múltiples destinos usando OSRM Table API
  Future<List<double>> obtenerDistanciasMatrix(LatLng origen, List<LatLng> destinos) async {
    if (destinos.isEmpty) return [];

    // OSRM Table API URL: {origen};{destino1};{destino2}...
    final coordStrings = destinos.map((d) => '${d.longitude},${d.latitude}').toList();
    coordStrings.insert(0, '${origen.longitude},${origen.latitude}');
    final coordinates = coordStrings.join(';');
    
    final url = Uri.parse(
      'https://router.project-osrm.org/table/v1/driving/$coordinates?sources=0&annotations=distance',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['distances'] != null && (data['distances'] as List).isNotEmpty) {
          final distancesList = data['distances'][0] as List;
          // El primer elemento es el origen al origen (0), lo ignoramos
          return distancesList.skip(1).map((d) => (d as num).toDouble()).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error en obtenerDistanciasMatrix: $e');
      return [];
    }
  }
}

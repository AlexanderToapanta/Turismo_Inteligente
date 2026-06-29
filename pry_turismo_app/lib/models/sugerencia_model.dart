import 'package:cloud_firestore/cloud_firestore.dart';

class SugerenciaModel {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String correoUsuario;
  final String nombreLugar;
  final String tipoLugar;
  final double latitud;
  final double longitud;
  final String horarioAtencion;
  final String? fotoUrl;
  final String estado; // 'pendiente', 'aprobado', 'rechazado'
  final DateTime fecha;

  const SugerenciaModel({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.correoUsuario,
    required this.nombreLugar,
    required this.tipoLugar,
    required this.latitud,
    required this.longitud,
    required this.horarioAtencion,
    this.fotoUrl,
    required this.estado,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'correoUsuario': correoUsuario,
      'nombreLugar': nombreLugar,
      'tipoLugar': tipoLugar,
      'latitud': latitud,
      'longitud': longitud,
      'horarioAtencion': horarioAtencion,
      'fotoUrl': fotoUrl,
      'estado': estado,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  factory SugerenciaModel.fromMap(Map<String, dynamic> map, String id) {
    return SugerenciaModel(
      id: id,
      usuarioId: map['usuarioId'] as String? ?? '',
      nombreUsuario: map['nombreUsuario'] as String? ?? 'Usuario Anónimo',
      correoUsuario: map['correoUsuario'] as String? ?? 'Sin correo',
      nombreLugar: map['nombreLugar'] as String? ?? '',
      tipoLugar: map['tipoLugar'] as String? ?? 'comida',
      latitud: (map['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (map['longitud'] as num?)?.toDouble() ?? 0.0,
      horarioAtencion: map['horarioAtencion'] as String? ?? '',
      fotoUrl: map['fotoUrl'] as String?,
      estado: map['estado'] as String? ?? 'pendiente',
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

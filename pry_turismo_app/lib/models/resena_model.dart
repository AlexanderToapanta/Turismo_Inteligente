import 'package:cloud_firestore/cloud_firestore.dart';

class ResenaModel {
  final String id;
  final String idUsuario;
  final String nombreUsuario;
  final String idLugar;
  final String nombreLugar;
  final String titulo;
  final String comentario;
  final int calificacion;
  final String? imagenUrl;
  final DateTime fecha;

  const ResenaModel({
    required this.id,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.idLugar,
    required this.nombreLugar,
    required this.titulo,
    required this.comentario,
    required this.calificacion,
    this.imagenUrl,
    required this.fecha,
  });

  // ── Serialización ────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'nombreUsuario': nombreUsuario,
      'idLugar': idLugar,
      'nombreLugar': nombreLugar,
      'titulo': titulo,
      'comentario': comentario,
      'calificacion': calificacion,
      'imagenUrl': imagenUrl,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  factory ResenaModel.fromMap(Map<String, dynamic> map, String docId) {
    return ResenaModel(
      id: docId,
      idUsuario: map['idUsuario'] as String,
      nombreUsuario: map['nombreUsuario'] as String,
      idLugar: map['idLugar'] as String,
      nombreLugar: map['nombreLugar'] as String,
      titulo: map['titulo'] as String,
      comentario: map['comentario'] as String,
      calificacion: (map['calificacion'] as num).toInt(),
      imagenUrl: map['imagenUrl'] as String?,
      fecha: (map['fecha'] as Timestamp).toDate(),
    );
  }
}

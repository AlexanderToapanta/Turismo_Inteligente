import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final DateTime fechaRegistro;

  const UsuarioModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.fechaRegistro,
  });

  // ── Serialización ────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      correo: map['correo'] as String,
      rol: map['rol'] as String,
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
    );
  }
}

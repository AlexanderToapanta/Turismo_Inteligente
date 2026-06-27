import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resena_model.dart';
import '../models/lugar_model.dart';
import 'cloudinary_service.dart';

class ResenaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinary = CloudinaryService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('resenas');

  CollectionReference<Map<String, dynamic>> get _colLugares =>
      _firestore.collection('lugares');

  // ─────────────────────────────────────────────────────────
  /// Crea una nueva reseña en Firestore.
  /// Si [imagenFile] no es null la sube a Cloudinary primero.
  // ─────────────────────────────────────────────────────────
  Future<void> crearResena({
    required String idUsuario,
    required String nombreUsuario,
    required String idLugar,
    required String nombreLugar,
    required String titulo,
    required String comentario,
    required int calificacion,
    File? imagenFile,
  }) async {
    String? imagenUrl;

    // Subir imagen a Cloudinary si el usuario seleccionó una
    if (imagenFile != null) {
      imagenUrl = await _cloudinary.uploadImage(imagenFile);
    }

    // Crear documento con ID automático de Firestore
    final docRef = _col.doc();

    final resena = ResenaModel(
      id: docRef.id,
      idUsuario: idUsuario,
      nombreUsuario: nombreUsuario,
      idLugar: idLugar,
      nombreLugar: nombreLugar,
      titulo: titulo,
      comentario: comentario,
      calificacion: calificacion,
      imagenUrl: imagenUrl,
      fecha: DateTime.now(),
    );

    await docRef.set(resena.toMap());
  }

  // ─────────────────────────────────────────────────────────
  /// Obtiene todas las reseñas ordenadas por fecha descendente.
  // ─────────────────────────────────────────────────────────
  Future<List<ResenaModel>> obtenerResenas() async {
    final snapshot =
        await _col.orderBy('fecha', descending: true).get();

    return snapshot.docs
        .map((doc) => ResenaModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ─────────────────────────────────────────────────────────
  /// Obtiene las reseñas de un lugar específico, ordenadas
  /// por fecha descendente.
  // ─────────────────────────────────────────────────────────
  Future<List<ResenaModel>> obtenerResenasPorLugar(String idLugar) async {
    final snapshot = await _col
        .where('idLugar', isEqualTo: idLugar)
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ResenaModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ─────────────────────────────────────────────────────────
  /// Carga todos los documentos de la colección "lugares"
  /// para poblar el dropdown del formulario de reseñas.
  // ─────────────────────────────────────────────────────────
  Future<List<LugarModel>> obtenerLugares() async {
    final snapshot = await _colLugares.orderBy('nombre').get();

    return snapshot.docs
        .map((doc) => LugarModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}

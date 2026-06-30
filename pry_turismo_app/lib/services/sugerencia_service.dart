import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sugerencia_model.dart';
import '../models/sitio_turistico.dart';

class SugerenciaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('sugerencias');

  // ─────────────────────────────────────────────────────────
  /// Crea una nueva sugerencia.
  // ─────────────────────────────────────────────────────────
  Future<void> agregarSugerencia(SugerenciaModel sugerencia) async {
    final docRef = _col.doc();
    final map = sugerencia.toMap();
    map['id'] = docRef.id;
    await docRef.set(map);
  }

  // ─────────────────────────────────────────────────────────
  /// Obtiene todas las sugerencias de un usuario específico.
  // ─────────────────────────────────────────────────────────
  Stream<List<SugerenciaModel>> obtenerSugerenciasUsuario(String usuarioId) {
    return _col
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs
          .map((doc) => SugerenciaModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // Ordenar localmente por fecha descendente para evitar requerir un índice compuesto en Firestore
      lista.sort((a, b) => b.fecha.compareTo(a.fecha));
      
      return lista;
    });
  }

  // ─────────────────────────────────────────────────────────
  /// Obtiene todas las sugerencias (para el administrador).
  // ─────────────────────────────────────────────────────────
  Stream<List<SugerenciaModel>> obtenerTodasLasSugerencias() {
    return _col.orderBy('fecha', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SugerenciaModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ─────────────────────────────────────────────────────────
  /// Actualiza el estado de una sugerencia.
  // ─────────────────────────────────────────────────────────
  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    await _col.doc(id).update({'estado': nuevoEstado});
  }

  // ─────────────────────────────────────────────────────────
  /// Actualiza los datos editables de una sugerencia.
  // ─────────────────────────────────────────────────────────
  Future<void> actualizarDatosSugerencia({
    required String id,
    required String nombreLugar,
    required String horarioAtencion,
    required String tipoLugar,
  }) async {
    await _col.doc(id).update({
      'nombreLugar': nombreLugar,
      'horarioAtencion': horarioAtencion,
      'tipoLugar': tipoLugar,
    });
  }

  // ─────────────────────────────────────────────────────────
  /// Obtiene una sugerencia por su ID.
  // ─────────────────────────────────────────────────────────
  Future<SugerenciaModel?> obtenerSugerenciaPorId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return SugerenciaModel.fromMap(doc.data()!, doc.id);
  }

  // ─────────────────────────────────────────────────────────
  /// Elimina una sugerencia de Firestore y sus reseñas asociadas.
  // ─────────────────────────────────────────────────────────
  Future<void> eliminarSugerencia(String id) async {
    try {
      // 1. Obtener la sugerencia para conocer su nombre y borrar reseñas
      final doc = await _col.doc(id).get();
      if (doc.exists && doc.data() != null) {
        final nombreLugar = doc.data()!['nombreLugar'] as String?;
        if (nombreLugar != null) {
          final idLugar = nombreLugar.toLowerCase().replaceAll(' ', '_');
          // 2. Borrar todas las reseñas asociadas a este lugar
          final snapshotResenas = await _firestore
              .collection('resenas')
              .where('idLugar', isEqualTo: idLugar)
              .get();
          
          if (snapshotResenas.docs.isNotEmpty) {
            final batch = _firestore.batch();
            for (var resenaDoc in snapshotResenas.docs) {
              batch.delete(resenaDoc.reference);
            }
            await batch.commit();
          }
        }
      }
      
      // 3. Eliminar el documento de la sugerencia
      await _col.doc(id).delete();
    } catch (e) {
      print('Error al eliminar sugerencia y reseñas: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────
  /// Convierte sugerencias aprobadas en SitioTuristico para el mapa y listas.
  // ─────────────────────────────────────────────────────────
  Stream<List<SitioTuristico>> obtenerSugerenciasAprobadasComoSitios() {
    return _col
        .where('estado', isEqualTo: 'aprobado')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final s = SugerenciaModel.fromMap(doc.data(), doc.id);
        // Mapear tipoLugar -> categoria de SitioTuristico
        final categoria = _mapearTipo(s.tipoLugar);
        return SitioTuristico(
          nombre: s.nombreLugar,
          descripcion: '${categoria} sugerido por la comunidad',
          latitud: s.latitud,
          longitud: s.longitud,
          imagenUrl: s.fotoUrl ?? '',
          categoria: categoria,
          esSugerencia: true,
          horario: s.horarioAtencion,
          sugerenciaId: s.id,
        );
      }).toList();
    });
  }

  String _mapearTipo(String tipoLugar) {
    switch (tipoLugar.toLowerCase()) {
      case 'hoteles': return 'Hoteles';
      case 'cultura': return 'Cultura';
      case 'naturaleza': return 'Naturaleza';
      case 'comida': return 'Comida';
      default: return 'Otro';
    }
  }
}

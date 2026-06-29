import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';

/// Constante con el correo del administrador (en minúsculas).
const String _correoAdmin = 'alexandertoapanta05@gmail.com';

class UsuarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('usuarios');

  // ─────────────────────────────────────────────────────────
  /// Crea el documento en Firestore si todavía no existe.
  ///
  /// - [firebaseUser]: usuario autenticado por Firebase Auth.
  /// - [nombre]: nombre opcional (necesario en registro con correo).
  ///
  /// Si el documento con ese UID ya existe no lo modifica.
  // ─────────────────────────────────────────────────────────
  Future<void> crearDocumentoSiNoExiste(
    User firebaseUser, {
    String? nombre,
  }) async {
    final docRef = _col.doc(firebaseUser.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) return; // ya existe → no duplicar

    final correo = (firebaseUser.email ?? '').toLowerCase().trim();
    final rol = correo == _correoAdmin ? 'administrador' : 'usuario';

    final nombreFinal = nombre?.trim().isNotEmpty == true
        ? nombre!.trim()
        : (firebaseUser.displayName ?? 'Sin nombre');

    // Usamos FieldValue.serverTimestamp() para que la fecha la asigne el
    // servidor de Firestore (más confiable que DateTime.now() local).
    await docRef.set({
      'id': firebaseUser.uid,
      'nombre': nombreFinal,
      'correo': correo,
      'rol': rol,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────────────────
  /// Obtiene el documento del usuario desde Firestore.
  /// Devuelve null si no existe.
  // ─────────────────────────────────────────────────────────
  Future<UsuarioModel?> obtenerUsuario(String uid) async {
    final snapshot = await _col.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return UsuarioModel.fromMap(snapshot.data()!);
  }

  // ─────────────────────────────────────────────────────────
  /// Obtiene todos los usuarios.
  // ─────────────────────────────────────────────────────────
  Future<List<UsuarioModel>> obtenerTodosLosUsuarios() async {
    final snapshot = await _col.get();
    return snapshot.docs
        .map((doc) => UsuarioModel.fromMap(doc.data()))
        .toList();
  }

  // ─────────────────────────────────────────────────────────
  /// Actualiza el rol de un usuario.
  // ─────────────────────────────────────────────────────────
  Future<void> actualizarRolUsuario(String uid, String nuevoRol) async {
    await _col.doc(uid).update({'rol': nuevoRol});
  }
}

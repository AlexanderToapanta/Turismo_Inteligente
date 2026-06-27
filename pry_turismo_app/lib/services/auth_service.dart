import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'usuario_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final UsuarioService _usuarioService = UsuarioService();

  bool _inicializado = false;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ─────────────────────────────────────────────────────────
  Future<void> _inicializarGoogle() async {
    if (!_inicializado) {
      await _googleSignIn.initialize();
      _inicializado = true;
    }
  }

  // ─────────────────────────────────────────────────────────
  /// Registra un nuevo usuario con correo + contraseña y crea
  /// su documento en Firestore.
  // ─────────────────────────────────────────────────────────
  Future<User?> registrarConCorreo({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = credential.user;
      if (user != null) {
        // Actualizar displayName en Auth
        await user.updateDisplayName(nombre.trim());

        // Crear documento en Firestore
        await _usuarioService.crearDocumentoSiNoExiste(user, nombre: nombre);
      }

      return user;
    } catch (e) {
      print('Error en registrarConCorreo: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────
  /// Inicia sesión con Google. Si el documento de usuario no
  /// existe en Firestore, lo crea automáticamente.
  // ─────────────────────────────────────────────────────────
  Future<User?> signInWithGoogle() async {
    try {
      await _inicializarGoogle();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        // Crear documento sólo si no existe (check-then-create)
        await _usuarioService.crearDocumentoSiNoExiste(user);
      }

      return user;
    } catch (e) {
      print('Error en signInWithGoogle: $e');
      rethrow;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        await _usuarioService.crearDocumentoSiNoExiste(user);
      }

      return user;
    } catch (e) {
      print('Error en signInWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _inicializarGoogle();
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error en signOut: $e');
      rethrow;
    }
  }
}

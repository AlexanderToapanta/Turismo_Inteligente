import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/tema_turismo.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  // ─── Acción principal: validar → llamar al ViewModel → navegar ────────────
  Future<void> _crearCuenta(AuthViewModel authVM) async {
    // Limpiar mensaje previo del VM
    authVM.limpiarMensaje();

    if (!_formKey.currentState!.validate()) return;

    await authVM.registrarConCorreo(
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (authVM.usuario != null) {
      // Registro exitoso → AuthChecker en main.dart redirige automáticamente.
      // Cerramos el stack de registro para volver al flujo principal.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (authVM.errorRegistro.isNotEmpty) {
      // Mostrar error como SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorRegistro),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    final bg = TemaPersona5.backgroundColor;
    final surface = TemaPersona5.surfaceColor;
    final primary = TemaPersona5.primaryColor;
    final textPrimary = TemaPersona5.textPrimary;
    final textSecondary = TemaPersona5.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CREAR CUENTA',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: primary,
            letterSpacing: 2,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Ícono decorativo ──────────────────────────
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 72,
                      color: primary,
                    ),
                  ),

                  // ── Campo: Nombre ─────────────────────────────
                  TextFormField(
                    controller: _nombreController,
                    style: TextStyle(color: textPrimary),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Nombre completo',
                      hintStyle: TextStyle(color: textSecondary),
                      prefixIcon: Icon(Icons.badge_outlined, color: primary),
                      filled: true,
                      fillColor: surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: surface),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: surface),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre no puede estar vacío.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Campo: Correo ─────────────────────────────
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: textPrimary),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Correo electrónico',
                      hintStyle: TextStyle(color: textSecondary),
                      prefixIcon:
                          Icon(Icons.email_outlined, color: primary),
                      filled: true,
                      fillColor: surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: surface),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: surface),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El correo no puede estar vacío.';
                      }
                      final emailRegex =
                          RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Ingresa un correo con formato válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Campo: Contraseña ─────────────────────────
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: textPrimary),
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Contraseña (mín. 6 caracteres)',
                      hintStyle: TextStyle(color: textSecondary),
                      prefixIcon: Icon(Icons.lock_outline, color: primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: surface),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: surface),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contraseña no puede estar vacía.';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener mínimo 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // ── Botón principal ───────────────────────────
                  ElevatedButton(
                    onPressed:
                        authVM.cargando ? null : () => _crearCuenta(authVM),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: textPrimary,
                      disabledBackgroundColor: primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: authVM.cargando
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: textPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'CREAR CUENTA',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // ── Volver al Login ───────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: authVM.cargando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ),

                  // ── Nota informativa ──────────────────────────
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14,
                          color: textSecondary.withValues(alpha: 0.6)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'El rol y la fecha de registro se asignan automáticamente.',
                          style: TextStyle(
                            color: textSecondary.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

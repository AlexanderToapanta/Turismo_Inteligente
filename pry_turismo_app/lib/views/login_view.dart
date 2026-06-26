import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/tema_turismo.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Utilizamos los colores del tema Persona 5
    final bg = TemaPersona5.backgroundColor;
    final surface = TemaPersona5.surfaceColor;
    final primary = TemaPersona5.primaryColor;
    final textPrimary = TemaPersona5.textPrimary;
    final textSecondary = TemaPersona5.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: textPrimary,
                      ) ??
                      TextStyle(
                        color: textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 48),

                // Campo de Usuario / Correo
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(color: textSecondary),
                    prefixIcon: Icon(Icons.person_outline, color: primary),
                    // Si el tema global se aplica, esto puede ser redundante, 
                    // pero lo aseguramos con los colores del tema
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: textSecondary),
                    prefixIcon: Icon(Icons.lock_outline, color: primary),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Checkbox Remember me
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        checkColor: bg,
                        activeColor: primary,
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return primary;
                          }
                          return textSecondary;
                        }),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botón Login
                ElevatedButton(
                  onPressed: authViewModel.cargando
                      ? null
                      : () {
                          authViewModel.signInWithEmailAndPassword(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: authViewModel.cargando
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: textPrimary, strokeWidth: 2),
                        )
                      : Text(
                          'LOGIN',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Forgot password
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Acción de olvidar contraseña
                    },
                    child: Text(
                      'Forgot your password?',
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Separador o texto de mensajes de error/éxito
                if (authViewModel.mensaje.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      authViewModel.mensaje,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: primary),
                    ),
                  ),

                // Botón Continuar con Google
                OutlinedButton.icon(
                  onPressed: authViewModel.cargando
                      ? null
                      : () {
                          authViewModel.signInWithGoogle();
                        },
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                    height: 24,
                  ),
                  label: Text(
                    'Continuar con Google',
                    style: TextStyle(color: textPrimary, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

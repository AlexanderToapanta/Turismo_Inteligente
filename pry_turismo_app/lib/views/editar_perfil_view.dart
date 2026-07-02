import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/tema_turismo.dart';
import '../viewmodels/auth_viewmodel.dart';

class EditarPerfilView extends StatefulWidget {
  const EditarPerfilView({super.key});

  @override
  State<EditarPerfilView> createState() => _EditarPerfilViewState();
}

class _EditarPerfilViewState extends State<EditarPerfilView> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    _nombreCtrl.text = authVm.usuarioModel?.nombre ?? '';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.bebasNeue(fontSize: 24, letterSpacing: 1.5),
        ),
        backgroundColor: TemaPersona5.surfaceColor,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authVm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: TemaPersona5.primaryColor,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un nombre' : null,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva Contraseña (opcional)',
                      hintText: 'Déjalo en blanco si no deseas cambiarla',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (val) {
                      if (val != null && val.isNotEmpty && val.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: authVm.cargando
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final error = await authVm.actualizarPerfil(
                                nuevoNombre: _nombreCtrl.text,
                                nuevaPassword: _passCtrl.text.isEmpty ? null : _passCtrl.text,
                              );

                              if (!context.mounted) return;

                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Perfil actualizado correctamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            }
                          },
                    child: authVm.cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('GUARDAR CAMBIOS'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

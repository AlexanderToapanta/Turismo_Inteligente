import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/tema_turismo.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/sugerencia_viewmodel.dart';

class CrearSugerenciaView extends StatefulWidget {
  const CrearSugerenciaView({super.key});

  @override
  State<CrearSugerenciaView> createState() => _CrearSugerenciaViewState();
}

class _CrearSugerenciaViewState extends State<CrearSugerenciaView> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _horarioCtrl = TextEditingController();
  String _tipoLugar = 'comida';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _horarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(SugerenciaViewModel vm) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      vm.setImagen(File(image.path));
    }
  }

  Future<void> _tomarFoto(SugerenciaViewModel vm) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      vm.setImagen(File(photo.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos ChangeNotifierProvider aquí o en main.dart. Aquí está bien para que el estado viva solo en esta vista.
    return ChangeNotifierProvider(
      create: (_) => SugerenciaViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sugerir Lugar',
            style: GoogleFonts.bebasNeue(fontSize: 24, letterSpacing: 1.5),
          ),
          backgroundColor: TemaPersona5.surfaceColor,
        ),
        body: Consumer<SugerenciaViewModel>(
          builder: (context, vm, _) {
            if (vm.enviando) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: TemaPersona5.primaryColor),
                    SizedBox(height: 16),
                    Text('Enviando sugerencia...'),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nombre
                  TextField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Lugar',
                      prefixIcon: Icon(Icons.place),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Horario
                  TextField(
                    controller: _horarioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Horario de Atención',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tipo de Lugar
                  DropdownButtonFormField<String>(
                    value: _tipoLugar,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Lugar',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'comida', child: Text('Comida')),
                      DropdownMenuItem(value: 'hoteles', child: Text('Hoteles')),
                      DropdownMenuItem(value: 'cultura', child: Text('Cultura')),
                      DropdownMenuItem(value: 'naturaleza', child: Text('Naturaleza')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _tipoLugar = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Ubicación
                  Text(
                    'Ubicación',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (vm.latitud != null && vm.longitud != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ubicación obtenida:\nLat: ${vm.latitud!.toStringAsFixed(4)}, Lng: ${vm.longitud!.toStringAsFixed(4)}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: vm.cargandoUbicacion
                          ? null
                          : () => vm.obtenerUbicacion(),
                      icon: vm.cargandoUbicacion
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location),
                      label: const Text('Obtener mi ubicación actual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TemaPersona5.surfaceColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Foto
                  Text(
                    'Foto del Local',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (vm.imagenSeleccionada != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            vm.imagenSeleccionada!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: vm.limpiarImagen,
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _tomarFoto(vm),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Cámara'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _seleccionarImagen(vm),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galería'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),

                  // Botón de Enviar
                  ElevatedButton(
                    onPressed: () async {
                      final authVm =
                          Provider.of<AuthViewModel>(context, listen: false);
                      final error = await vm.enviarSugerencia(
                        usuarioId: authVm.usuario!.uid,
                        nombreUsuario: authVm.usuarioModel?.nombre ?? authVm.usuario?.displayName ?? 'Usuario Anónimo',
                        correoUsuario: authVm.usuarioModel?.correo ?? authVm.usuario?.email ?? 'Sin correo',
                        nombreLugar: _nombreCtrl.text,
                        tipoLugar: _tipoLugar,
                        horarioAtencion: _horarioCtrl.text,
                      );

                      if (!context.mounted) return;

                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sugerencia enviada correctamente.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('ENVIAR SUGERENCIA'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

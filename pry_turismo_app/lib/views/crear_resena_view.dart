import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/sitio_turistico.dart';
import '../theme/tema_turismo.dart';
import '../viewmodels/resena_viewmodel.dart';
import '../viewmodels/turismo_viewmodel.dart';
import 'widgets/camera_picker_widget.dart';

class CrearResenaView extends StatefulWidget {
  const CrearResenaView({super.key});

  @override
  State<CrearResenaView> createState() => _CrearResenaViewState();
}

class _CrearResenaViewState extends State<CrearResenaView> {
  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _comentarioCtrl = TextEditingController();

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  Future<void> _publicar(ResenaViewModel vm) async {
    final error = await vm.publicarResena(
      titulo: _tituloCtrl.text,
      comentario: _comentarioCtrl.text,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: TemaPersona5.primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reseña publicada!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResenaViewModel>();

    return Scaffold(
      backgroundColor: TemaPersona5.backgroundColor,
      appBar: AppBar(title: const Text('Nueva reseña')),
      body: vm.publicando
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Publicando reseña…'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Campo: Título ───────────────────────────
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título de la reseña',
                      hintText: 'Ej. Un lugar increíble',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),

                  // ── Dropdown: Lugar (desde OpenStreetMap) ─────────
                  _buildDropdownLugares(context, vm),
                  const SizedBox(height: 24),

                  // ── Selector de calificación ─────────────────
                  Text('Calificación',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => vm.setCalificacion(index + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < vm.calificacion
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 44,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // ── Campo: Comentario ────────────────────────
                  TextFormField(
                    controller: _comentarioCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Comentario',
                      hintText: 'Cuéntanos tu experiencia…',
                      alignLabelWithHint: true,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // ── Sección: Fotografía ──────────────────────
                  Text('Fotografía (Opcional)',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  CameraPickerWidget(
                    imagePath: vm.imagenSeleccionada?.path,
                    onImageSelected: (path) => vm.setImagen(File(path)),
                  ),
                  const SizedBox(height: 32),

                  // ── Botón: Publicar reseña ───────────────────
                  ElevatedButton(
                    onPressed: () => _publicar(vm),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Publicar reseña',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────
  Widget _buildDropdownLugares(BuildContext context, ResenaViewModel vm) {
    // Lee los lugares directamente del TurismoViewModel (OpenStreetMap)
    final sitios = context.watch<TurismoViewModel>().sitiosCercanos;
    final cargando = context.watch<TurismoViewModel>().cargando;

    return DropdownButtonFormField<SitioTuristico>(
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Lugar turístico'),
      dropdownColor: TemaPersona5.surfaceColor,
      value: sitios.contains(vm.lugarSeleccionado) ? vm.lugarSeleccionado : null,
      hint: Text(
        cargando
            ? 'Cargando lugares…'
            : sitios.isEmpty
                ? 'No hay lugares cercanos'
                : 'Selecciona un lugar',
        style: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
      items: sitios.map((SitioTuristico sitio) {
        return DropdownMenuItem<SitioTuristico>(
          value: sitio,
          child: Text(
            sitio.nombre,
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: sitios.isEmpty
          ? null
          : (SitioTuristico? sitio) {
              if (sitio != null) vm.seleccionarLugar(sitio);
            },
    );
  }
}

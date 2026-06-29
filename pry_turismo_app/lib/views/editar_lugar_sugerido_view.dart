import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sugerencia_model.dart';
import '../services/sugerencia_service.dart';
import '../theme/tema_turismo.dart';

class EditarLugarSugeridoView extends StatefulWidget {
  final SugerenciaModel sugerencia;

  const EditarLugarSugeridoView({super.key, required this.sugerencia});

  @override
  State<EditarLugarSugeridoView> createState() => _EditarLugarSugeridoViewState();
}

class _EditarLugarSugeridoViewState extends State<EditarLugarSugeridoView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _horarioCtrl;
  late String _tipoLugar;
  bool _guardando = false;

  final List<String> _tipos = ['hoteles', 'cultura', 'naturaleza', 'comida'];

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.sugerencia.nombreLugar);
    _horarioCtrl = TextEditingController(text: widget.sugerencia.horarioAtencion);
    _tipoLugar = widget.sugerencia.tipoLugar;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _horarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    try {
      await SugerenciaService().actualizarDatosSugerencia(
        id: widget.sugerencia.id,
        nombreLugar: _nombreCtrl.text.trim(),
        horarioAtencion: _horarioCtrl.text.trim(),
        tipoLugar: _tipoLugar,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lugar actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaPersona5.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Editar Lugar',
          style: GoogleFonts.bebasNeue(
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        actions: [
          if (_guardando)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _guardar,
              child: Text(
                'GUARDAR',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(label: 'Sugerido por'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: TemaPersona5.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sugerencia.nombreUsuario,
                            style: GoogleFonts.poppins(
                              color: TemaPersona5.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.sugerencia.correoUsuario,
                            style: GoogleFonts.poppins(
                              color: TemaPersona5.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel(label: 'Nombre del lugar'),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: _nombreCtrl,
                hintText: 'Nombre del lugar turistico',
                icon: Icons.place_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Horario de atencion'),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: _horarioCtrl,
                hintText: 'Ej. Lunes a Viernes 8:00-18:00',
                icon: Icons.access_time_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El horario es obligatorio' : null,
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Tipo de lugar'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _tipoLugar,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: GoogleFonts.poppins(color: TemaPersona5.textPrimary, fontSize: 14),
                    icon: const Icon(Icons.expand_more, color: TemaPersona5.textSecondary),
                    items: _tipos.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo[0].toUpperCase() + tipo.substring(1)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _tipoLugar = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel(label: 'Ubicacion (solo lectura)'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: TemaPersona5.textSecondary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Lat: ${widget.sugerencia.latitud.toStringAsFixed(5)}, '
                      'Lon: ${widget.sugerencia.longitud.toStringAsFixed(5)}',
                      style: GoogleFonts.poppins(
                        color: TemaPersona5.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    'GUARDAR CAMBIOS',
                    style: GoogleFonts.bebasNeue(fontSize: 18, letterSpacing: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: TemaPersona5.primaryColor,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: TemaPersona5.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: TemaPersona5.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: TemaPersona5.primaryColor, size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: TemaPersona5.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

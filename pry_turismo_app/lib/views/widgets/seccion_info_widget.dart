import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/tema_turismo.dart';

class SeccionInfoWidget extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String contenido;

  const SeccionInfoWidget({
    super.key,
    required this.icono,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: TemaPersona5.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TemaPersona5.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contenido,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TemaPersona5.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

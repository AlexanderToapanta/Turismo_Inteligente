import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/tema_turismo.dart';

class SeccionHorariosWidget extends StatelessWidget {
  final List<String> horarios;

  const SeccionHorariosWidget({super.key, required this.horarios});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.access_time,
            color: TemaPersona5.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horarios',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TemaPersona5.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...horarios.map(
                  (dia) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      dia,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: TemaPersona5.textSecondary,
                      ),
                    ),
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

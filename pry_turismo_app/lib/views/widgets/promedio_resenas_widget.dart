import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/tema_turismo.dart';

class PromedioResenasWidget extends StatelessWidget {
  final bool cargandoPromedio;
  final Map<String, dynamic>? promedioResenas;

  const PromedioResenasWidget({
    super.key,
    required this.cargandoPromedio,
    required this.promedioResenas,
  });

  @override
  Widget build(BuildContext context) {
    if (cargandoPromedio) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: TemaPersona5.primaryColor,
          ),
        ),
      );
    }

    if (promedioResenas == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Aún no tiene reseñas asignadas',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: TemaPersona5.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final double promedio = promedioResenas!['promedio'] as double;
    final int total = promedioResenas!['total'] as int;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: TemaPersona5.secondaryColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: TemaPersona5.primaryColor, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: TemaPersona5.primaryColor, size: 14),
            const SizedBox(width: 3),
            Text(
              promedio.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: TemaPersona5.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '($total reseñas de la app)',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: TemaPersona5.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/tema_turismo.dart';

class PromedioResenasSugerenciaWidget extends StatelessWidget {
  final bool cargandoPromedio;
  final Map<String, dynamic>? promedioResenas;

  const PromedioResenasSugerenciaWidget({
    super.key,
    required this.cargandoPromedio,
    required this.promedioResenas,
  });

  @override
  Widget build(BuildContext context) {
    if (cargandoPromedio) {
      return const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TemaPersona5.primaryColor,
            ),
          ),
          SizedBox(width: 10),
          Text('Cargando reseñas de la comunidad...'),
        ],
      );
    }

    if (promedioResenas == null) {
      return Text(
        'Este lugar sugerido aún no tiene reseñas.',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: TemaPersona5.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final double promedio = promedioResenas!['promedio'] as double;
    final int total = promedioResenas!['total'] as int;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TemaPersona5.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TemaPersona5.primaryColor, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: TemaPersona5.primaryColor),
          const SizedBox(width: 8),
          Text(
            promedio.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TemaPersona5.primaryColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($total reseñas de la comunidad)',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: TemaPersona5.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

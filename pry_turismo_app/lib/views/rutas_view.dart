import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/turismo_viewmodel.dart';
import '../theme/tema_turismo.dart';

class RutasView extends StatelessWidget {
  const RutasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TurismoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.cargando) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TemaPersona5.primaryColor),
            ),
          );
        }

        double direccion = viewModel.rumbo ?? 0;
        bool tieneSitioSeleccionado = viewModel.sitioSeleccionado != null;
        double? azimutHacia = viewModel.azimutHaciaSitio;

        return Container(
          color: TemaPersona5.backgroundColor,
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: isLandscape ? 120 : 100, // Espacio para el BottomNavBar
                ),
                child: Column(
                  children: [
                    // ─── Sección superior: brújula y textos ───
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      constraints: BoxConstraints(
                        minHeight: isLandscape ? 180 : 250,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Brújula ──
                          Expanded(
                            flex: 2,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                margin: const EdgeInsets.only(left: 16, right: 8),
                                decoration: BoxDecoration(
                                  color: TemaPersona5.surfaceColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: TemaPersona5.primaryColor.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: TemaPersona5.primaryColor.withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double diameter = math.min(constraints.maxWidth, constraints.maxHeight) * 0.85;
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: diameter,
                                          height: diameter,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: TemaPersona5.primaryColor.withValues(alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        Transform.rotate(
                                          angle: -(direccion * math.pi / 180),
                                          child: _BrujulaRosa(size: diameter),
                                        ),
                                        Icon(
                                          Icons.navigation,
                                          color: const Color(0xFFFF6600),
                                          size: diameter * 0.35,
                                        ),
                                        if (tieneSitioSeleccionado && azimutHacia != null)
                                          Transform.rotate(
                                            angle: (azimutHacia - direccion) * math.pi / 180,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 3,
                                                  height: diameter * 0.45,
                                                  decoration: BoxDecoration(
                                                    color: TemaPersona5.primaryColor,
                                                    borderRadius: BorderRadius.circular(2),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: TemaPersona5.primaryColor.withValues(alpha: 0.6),
                                                        blurRadius: 6,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Positioned(
                                          bottom: diameter * 0.05,
                                          child: Text(
                                            '${direccion.toStringAsFixed(0)}°',
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 12,
                                              color: TemaPersona5.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // ── Panel de info ──
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RUTAS',
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: isLandscape ? 28 : 32,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (tieneSitioSeleccionado) ...[
                                    Text(
                                      'Navegando hacia',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      viewModel.sitioSeleccionado!.nombre,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: isLandscape ? 14 : 16,
                                        fontWeight: FontWeight.w700,
                                        color: TemaPersona5.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _InfoChip(
                                          icon: Icons.straighten,
                                          label: viewModel.formatearDistancia(
                                            viewModel.obtenerDistancia(viewModel.sitioSeleccionado!),
                                          ),
                                          color: TemaPersona5.primaryColor,
                                        ),
                                        _InfoChip(
                                          icon: Icons.explore,
                                          label: viewModel.obtenerDireccionCardinal(viewModel.sitioSeleccionado!),
                                          color: const Color(0xFFFF6600),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Text(
                                      'Selecciona un sitio\nen el mapa para navegar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.white38,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── Divisor ───
                    const Divider(color: TemaPersona5.dividerColor, height: 1),

                    // ─── Sección inferior: detalles de orientación ───
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORIENTACIÓN',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 18,
                              color: Colors.white54,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Fila de datos
                          Row(
                            children: [
                              Expanded(
                                child: _DataCard(
                                  title: 'RUMBO',
                                  value: '${direccion.toStringAsFixed(1)}°',
                                  subtitle: _obtenerDireccionDesdeRumbo(direccion),
                                  accentColor: TemaPersona5.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DataCard(
                                  title: 'AZIMUT',
                                  value: tieneSitioSeleccionado && azimutHacia != null
                                      ? '${azimutHacia.toStringAsFixed(1)}°'
                                      : '--',
                                  subtitle: tieneSitioSeleccionado && azimutHacia != null
                                      ? _obtenerDireccionDesdeRumbo(azimutHacia)
                                      : 'Sin destino',
                                  accentColor: const Color(0xFFFF6600),
                                ),
                              ),
                            ],
                          ),

                          if (tieneSitioSeleccionado) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => viewModel.limpiarRuta(),
                                icon: const Icon(Icons.close, color: TemaPersona5.primaryColor, size: 18),
                                label: Text(
                                  'CANCELAR NAVEGACIÓN',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 16,
                                    color: TemaPersona5.primaryColor,
                                    letterSpacing: 2,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: TemaPersona5.primaryColor, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: TemaPersona5.surfaceColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: TemaPersona5.dividerColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Color(0xFF666666), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Ve al mapa, toca un marcador y selecciona "Navegar" para activar la brújula.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white38,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _obtenerDireccionDesdeRumbo(double rumbo) {
    if (rumbo >= 337.5 || rumbo < 22.5) return 'NORTE';
    if (rumbo >= 22.5 && rumbo < 67.5) return 'NORESTE';
    if (rumbo >= 67.5 && rumbo < 112.5) return 'ESTE';
    if (rumbo >= 112.5 && rumbo < 157.5) return 'SURESTE';
    if (rumbo >= 157.5 && rumbo < 202.5) return 'SUR';
    if (rumbo >= 202.5 && rumbo < 247.5) return 'SUROESTE';
    if (rumbo >= 247.5 && rumbo < 292.5) return 'OESTE';
    if (rumbo >= 292.5 && rumbo < 337.5) return 'NOROESTE';
    return 'NORTE';
  }
}

class _BrujulaRosa extends StatelessWidget {
  final double? size;
  const _BrujulaRosa({this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            child: Text(
              'N',
              style: GoogleFonts.bebasNeue(
                fontSize: 14,
                color: TemaPersona5.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            child: Text('S', style: GoogleFonts.bebasNeue(fontSize: 11, color: Colors.white54)),
          ),
          Positioned(
            right: 8,
            child: Text('E', style: GoogleFonts.bebasNeue(fontSize: 11, color: Colors.white54)),
          ),
          Positioned(
            left: 8,
            child: Text('O', style: GoogleFonts.bebasNeue(fontSize: 11, color: Colors.white54)),
          ),
          Container(width: 1, height: 40, color: Colors.white12),
          Container(width: 40, height: 1, color: Colors.white12),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accentColor;

  const _DataCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TemaPersona5.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.bebasNeue(fontSize: 12, color: Colors.white38, letterSpacing: 2),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.bebasNeue(fontSize: 28, color: accentColor, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/turismo_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/sugerencia_service.dart';
import 'detalle_lugar_view.dart';
import 'editar_lugar_sugerido_view.dart';
import '../theme/tema_turismo.dart';

class ListaSitiosView extends StatelessWidget {
  const ListaSitiosView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isAdmin = authViewModel.usuarioModel?.rol == 'administrador';

    return Consumer<TurismoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.cargando && viewModel.sitiosCercanos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(TemaPersona5.primaryColor),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cargando lugares cercanos...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TemaPersona5.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (viewModel.error != null && viewModel.sitiosCercanos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: TemaPersona5.primaryColor.withOpacity(0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 24,
                      color: TemaPersona5.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error ?? 'Error desconocido',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: TemaPersona5.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.sitiosCercanos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    size: 64,
                    color: TemaPersona5.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay lugares cercanos',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 24,
                      color: TemaPersona5.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intenta moverte a una zona turística',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: TemaPersona5.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            GridView.builder(
              itemCount: viewModel.sitiosFiltrados.length,
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                bottom: 100, // Evitar solapamiento con el BottomNavigationBar
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final sitio = viewModel.sitiosFiltrados[index];
                final distancia = viewModel.obtenerDistancia(sitio);
                final direccion = viewModel.obtenerDireccionCardinal(sitio);

                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleLugarView(sitio: sitio),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Imagen con overlay de botones admin
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                child: SizedBox.expand(
                                  child: sitio.imagenUrl.isNotEmpty
                                      ? Image.network(
                                          sitio.imagenUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                                color: TemaPersona5.surfaceColor,
                                                child: const Icon(Icons.image_not_supported, color: TemaPersona5.textSecondary),
                                              ),
                                        )
                                      : Container(
                                          color: TemaPersona5.surfaceColor,
                                          child: const Icon(Icons.image_not_supported, color: TemaPersona5.textSecondary),
                                        ),
                                ),
                              ),
                              // Botones admin sobre la imagen (solo lugares sugeridos)
                              if (isAdmin && sitio.esSugerencia)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _AdminIconBtn(
                                        icon: Icons.edit,
                                        color: Colors.blue,
                                        onTap: () async {
                                          if (sitio.sugerenciaId == null) return;
                                          final sugerencia = await SugerenciaService()
                                              .obtenerSugerenciaPorId(sitio.sugerenciaId!);
                                          if (sugerencia == null) return;
                                          if (!context.mounted) return;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditarLugarSugeridoView(
                                                sugerencia: sugerencia,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      _AdminIconBtn(
                                        icon: Icons.delete,
                                        color: Colors.red,
                                        onTap: () async {
                                          final confirmar = await _mostrarDialogoEliminar(
                                            context,
                                            titulo: 'Eliminar lugar',
                                            mensaje: '¿Deseas eliminar "${sitio.nombre}" de los lugares de la comunidad? Esta acción no se puede deshacer.',
                                          );
                                          if (confirmar == true && sitio.sugerenciaId != null) {
                                            await SugerenciaService().eliminarSugerencia(sitio.sugerenciaId!);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Lugar eliminado'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Contenido
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sitio.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 18,
                                    color: TemaPersona5.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sitio.descripcion,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: TemaPersona5.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                // Distancia
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: TemaPersona5.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        viewModel.formatearDistancia(distancia),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: TemaPersona5.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Dirección
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.explore,
                                      size: 14,
                                      color: TemaPersona5.secondaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        direccion,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: TemaPersona5.secondaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Indicador de carga de lugares
            if (viewModel.cargandoLugares)
              Positioned(
                bottom: 90,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: TemaPersona5.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: TemaPersona5.secondaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            TemaPersona5.secondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Actualizando lugares...',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: TemaPersona5.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Widget de botón admin para overlay ──────────────────
class _AdminIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ── Diálogo de confirmación con tema oscuro ─────────────────
Future<bool?> _mostrarDialogoEliminar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                color: TemaPersona5.primaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF444444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Eliminar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

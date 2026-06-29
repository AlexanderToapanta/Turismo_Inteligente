import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/resena_model.dart';
import '../theme/tema_turismo.dart';
import '../viewmodels/resena_viewmodel.dart';

class ResenasView extends StatelessWidget {
  const ResenasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ResenaViewModel>(
      builder: (context, vm, _) {
        if (vm.cargando) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return _buildError(vm.error!, vm);
        }

        if (vm.resenas.isEmpty) {
          return _buildEmptyState();
        }

        return _buildReviewList(context, vm.resenas);
      },
    );
  }

  // ── Estado de error ──────────────────────────────────────
  Widget _buildError(String error, ResenaViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: TemaPersona5.primaryColor),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: TemaPersona5.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: vm.cargarResenas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estado vacío ─────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rate_review_outlined, size: 80, color: TemaPersona5.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Descubre y comparte tus experiencias',
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                  fontSize: 32, color: TemaPersona5.textPrimary, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Lee las opiniones de otros viajeros o publica tu propia reseña sobre los lugares turísticos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: TemaPersona5.textSecondary),
            ),
            const SizedBox(height: 32),
            Text(
              'Aún no hay reseñas.\n¡Sé el primero en publicar una!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TemaPersona5.textSecondary.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Lista de tarjetas ────────────────────────────────────
  Widget _buildReviewList(BuildContext context, List<ResenaModel> resenas) {
    return RefreshIndicator(
      color: TemaPersona5.primaryColor,
      onRefresh: () => context.read<ResenaViewModel>().cargarResenas(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: resenas.length,
        itemBuilder: (context, i) => _ReviewCard(resena: resenas[i]),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Tarjeta de reseña
// ──────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final ResenaModel resena;

  const _ReviewCard({required this.resena});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isAdmin = authViewModel.usuarioModel?.rol == 'administrador';
    final fechaFormateada =
        DateFormat('d MMM yyyy', 'es').format(resena.fecha);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen (opcional)
          if (resena.imagenUrl != null)
            Image.network(
              resena.imagenUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, prog) => prog == null
                  ? child
                  : Container(
                      height: 180,
                      color: const Color(0xFF1A1A1A),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (ctx, err, st) => _imagePlaceholder(),
            )
          else
            _imagePlaceholder(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + estrellas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(resena.titulo,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < resena.calificacion
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Nombre del lugar
                Text(
                  resena.nombreLugar,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: TemaPersona5.primaryColor),
                ),
                const SizedBox(height: 12),
                // Comentario
                Text(resena.comentario,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                // Usuario + fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.person,
                          size: 16, color: TemaPersona5.textSecondary),
                      const SizedBox(width: 4),
                      Text(resena.nombreUsuario,
                          style: Theme.of(context).textTheme.labelMedium),
                    ]),
                    Text(fechaFormateada,
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final confirmar = await _mostrarDialogoEliminarResena(context);
                          if (confirmar == true) {
                            await context.read<ResenaViewModel>().eliminarResena(resena.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reseña eliminada'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      child: const Icon(Icons.image_outlined, size: 48, color: Color(0xFF444444)),
    );
  }
}

// ── Diálogo de confirmación con tema oscuro para reseñas ────
Future<bool?> _mostrarDialogoEliminarResena(BuildContext context) {
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
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Eliminar reseña',
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Estás seguro de que deseas eliminar esta reseña? Esta acción no se puede deshacer.',
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

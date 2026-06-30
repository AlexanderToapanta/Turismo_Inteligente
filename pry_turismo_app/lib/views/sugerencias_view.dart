import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sugerencia_model.dart';
import '../theme/tema_turismo.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/sugerencia_viewmodel.dart';

class SugerenciasView extends StatefulWidget {
  const SugerenciasView({super.key});

  @override
  State<SugerenciasView> createState() => _SugerenciasViewState();
}

class _SugerenciasViewState extends State<SugerenciasView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.usuario != null) {
        context.read<SugerenciaViewModel>().cargarMisSugerencias(authVM.usuario!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final usuarioId = authViewModel.usuario?.uid;

    if (usuarioId == null) {
      return const Center(child: Text('Inicia sesión para ver tus sugerencias'));
    }

    return Consumer<SugerenciaViewModel>(
      builder: (context, vm, _) {
        if (vm.cargandoMisSugerencias && vm.misSugerencias.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.errorMisSugerencias != null && vm.misSugerencias.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: TemaPersona5.primaryColor),
                  const SizedBox(height: 16),
                  Text(vm.errorMisSugerencias!, textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14, color: TemaPersona5.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => vm.cargarMisSugerencias(usuarioId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (vm.misSugerencias.isEmpty) {
          return _buildEmptyState(vm, usuarioId);
        }

        return RefreshIndicator(
          onRefresh: () => vm.cargarMisSugerencias(usuarioId),
          color: TemaPersona5.primaryColor,
          backgroundColor: TemaPersona5.surfaceColor,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: vm.misSugerencias.length,
            itemBuilder: (context, i) => _SugerenciaCard(sugerencia: vm.misSugerencias[i]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(SugerenciaViewModel vm, String usuarioId) {
    return RefreshIndicator(
      onRefresh: () => vm.cargarMisSugerencias(usuarioId),
      child: Stack(
        children: [
          ListView(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_location_alt_outlined,
                      size: 80, color: TemaPersona5.primaryColor),
                  const SizedBox(height: 24),
                  Text(
                    'Sugiérenos un lugar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                        fontSize: 32,
                        color: TemaPersona5.textPrimary,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no has sugerido ningún lugar turístico. ¡Anímate y ayúdanos a crecer!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: TemaPersona5.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SugerenciaCard extends StatelessWidget {
  final SugerenciaModel sugerencia;

  const _SugerenciaCard({required this.sugerencia});

  @override
  Widget build(BuildContext context) {
    final fechaFormateada =
        DateFormat('d MMM yyyy', 'es').format(sugerencia.fecha);

    Color estadoColor = Colors.grey;
    if (sugerencia.estado == 'aprobado') estadoColor = Colors.green;
    if (sugerencia.estado == 'rechazado') estadoColor = Colors.red;
    if (sugerencia.estado == 'pendiente') estadoColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sugerencia.fotoUrl != null)
            Image.network(
              sugerencia.fotoUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => _imagePlaceholder(),
            )
          else
            _imagePlaceholder(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(sugerencia.nombreLugar,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: estadoColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: estadoColor),
                      ),
                      child: Text(
                        sugerencia.estado.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: estadoColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Horario: ${sugerencia.horarioAtencion}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Tipo: ${sugerencia.tipoLugar[0].toUpperCase()}${sugerencia.tipoLugar.substring(1)}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  'Ubicación: ${sugerencia.latitud.toStringAsFixed(4)}, ${sugerencia.longitud.toStringAsFixed(4)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(fechaFormateada,
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
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

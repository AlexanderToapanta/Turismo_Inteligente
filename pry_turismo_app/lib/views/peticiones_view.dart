import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sugerencia_model.dart';
import '../theme/tema_turismo.dart';
import '../viewmodels/sugerencia_viewmodel.dart';

class PeticionesView extends StatefulWidget {
  const PeticionesView({super.key});

  @override
  State<PeticionesView> createState() => _PeticionesViewState();
}

class _PeticionesViewState extends State<PeticionesView> {
  @override
  void initState() {
    super.initState();
    // Cargar peticiones al iniciar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SugerenciaViewModel>().cargarTodasLasPeticiones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SugerenciaViewModel>(
      builder: (context, vm, child) {
        if (vm.cargandoPeticiones && vm.peticiones.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TemaPersona5.primaryColor),
            ),
          );
        }

        if (vm.errorPeticiones != null && vm.peticiones.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: TemaPersona5.primaryColor),
                  const SizedBox(height: 16),
                  Text(vm.errorPeticiones!, textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14, color: TemaPersona5.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => vm.cargarTodasLasPeticiones(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (vm.peticiones.isEmpty) {
          return _buildEmptyState(vm);
        }

        return RefreshIndicator(
          onRefresh: () => vm.cargarTodasLasPeticiones(),
          color: TemaPersona5.primaryColor,
          backgroundColor: TemaPersona5.surfaceColor,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: vm.peticiones.length,
            itemBuilder: (context, i) => _PeticionCard(
              peticion: vm.peticiones[i],
              vm: vm,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(SugerenciaViewModel vm) {
    return RefreshIndicator(
      onRefresh: () => vm.cargarTodasLasPeticiones(),
      child: Stack(
        children: [
          ListView(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 80, color: TemaPersona5.primaryColor),
                  const SizedBox(height: 24),
                  Text(
                    'No hay peticiones',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                        fontSize: 32,
                        color: TemaPersona5.textPrimary,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay lugares sugeridos pendientes por revisar.',
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

class _PeticionCard extends StatelessWidget {
  final SugerenciaModel peticion;
  final SugerenciaViewModel vm;

  const _PeticionCard({required this.peticion, required this.vm});

  @override
  Widget build(BuildContext context) {
    final fechaFormateada =
        DateFormat('d MMM yyyy', 'es').format(peticion.fecha);

    Color estadoColor = Colors.grey;
    if (peticion.estado == 'aprobado') estadoColor = Colors.green;
    if (peticion.estado == 'rechazado') estadoColor = Colors.red;
    if (peticion.estado == 'pendiente') estadoColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (peticion.fotoUrl != null)
            Image.network(
              peticion.fotoUrl!,
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
                      child: Text(peticion.nombreLugar,
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
                        peticion.estado.toUpperCase(),
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
                Text('Horario: ${peticion.horarioAtencion}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Tipo: ${peticion.tipoLugar[0].toUpperCase()}${peticion.tipoLugar.substring(1)}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  'Ubicación: ${peticion.latitud.toStringAsFixed(4)}, ${peticion.longitud.toStringAsFixed(4)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(peticion.nombreUsuario,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(peticion.correoUsuario,
                              style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                    Text(fechaFormateada,
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                if (peticion.estado == 'pendiente') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cambiarEstado(context, 'rechazado'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text('Rechazar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _cambiarEstado(context, 'aprobado'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text('Aprobar'),
                        ),
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

  Future<void> _cambiarEstado(BuildContext context, String nuevoEstado) async {
    await vm.actualizarEstadoPeticion(peticion.id, nuevoEstado);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Petición ${nuevoEstado == 'aprobado' ? 'aprobada' : 'rechazada'}'),
          backgroundColor: nuevoEstado == 'aprobado' ? Colors.green : Colors.red,
        ),
      );
    }
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

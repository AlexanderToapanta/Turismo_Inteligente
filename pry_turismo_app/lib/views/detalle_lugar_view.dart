import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/turismo_viewmodel.dart';
import '../models/sitio_turistico.dart';
import '../theme/tema_turismo.dart';

class DetalleLugarView extends StatefulWidget {
  final SitioTuristico sitio;

  const DetalleLugarView({super.key, required this.sitio});

  @override
  State<DetalleLugarView> createState() => _DetalleLugarViewState();
}

class _DetalleLugarViewState extends State<DetalleLugarView> {
  @override
  void initState() {
    super.initState();
    // Iniciar la carga de detalles apenas se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TurismoViewModel>(context, listen: false)
          .cargarDetallesLugar(widget.sitio);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TurismoViewModel>(
      builder: (context, viewModel, child) {
        final detalle = viewModel.detalleActual;
        final cargando = viewModel.cargandoDetalles;

        return Scaffold(
          backgroundColor: TemaPersona5.backgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: TemaPersona5.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: (detalle != null && detalle.fotos.isNotEmpty)
                      ? Image.network(
                          viewModel.placesService.obtenerUrlFoto(detalle.fotos.first),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _imagenPlaceholder(),
                        )
                      : Image.network(
                          widget.sitio.imagenUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _imagenPlaceholder(),
                        ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: TemaPersona5.secondaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y Rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.sitio.nombre,
                              style: GoogleFonts.bebasNeue(
                                fontSize: 32,
                                color: TemaPersona5.primaryColor,
                              ),
                            ),
                          ),
                          if (detalle != null && detalle.rating > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: TemaPersona5.secondaryColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: TemaPersona5.primaryColor, width: 2),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: TemaPersona5.primaryColor, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    detalle.rating.toString(),
                                    style: GoogleFonts.poppins(
                                      color: TemaPersona5.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Categoría
                      Text(
                        widget.sitio.categoria,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: TemaPersona5.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón Navegar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            viewModel.trazarRuta(widget.sitio);
                            Navigator.pop(context); // Cerrar detalle y volver al mapa
                          },
                          icon: const Icon(Icons.directions, color: TemaPersona5.secondaryColor),
                          label: const Text('Navegar hacia acá', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TemaPersona5.primaryColor,
                            foregroundColor: TemaPersona5.secondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Indicador de carga
                      if (cargando)
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(TemaPersona5.primaryColor),
                          ),
                        ),

                      // Detalles de Google Places
                      if (!cargando && detalle != null) ...[
                        _seccionInfo(
                          Icons.location_on,
                          'Dirección',
                          detalle.direccionCompleta,
                        ),
                        if (detalle.telefono != 'No disponible')
                          _seccionInfo(
                            Icons.phone,
                            'Teléfono',
                            detalle.telefono,
                          ),
                        if (detalle.sitioWeb != 'No disponible')
                          _seccionInfo(
                            Icons.language,
                            'Sitio Web',
                            detalle.sitioWeb,
                          ),
                        if (detalle.horarios.isNotEmpty)
                          _seccionHorarios(detalle.horarios),
                        
                        // Galería de fotos extra
                        if (detalle.fotos.length > 1) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Fotos',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 24,
                              color: TemaPersona5.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: detalle.fotos.length - 1,
                              itemBuilder: (context, i) {
                                // Empezamos desde el índice 1 porque la 0 ya está en el header
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      viewModel.placesService.obtenerUrlFoto(detalle.fotos[i+1]),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],

                      if (!cargando && detalle == null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(Icons.info_outline, color: TemaPersona5.textSecondary, size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  'Información detallada no disponible',
                                  style: GoogleFonts.poppins(color: TemaPersona5.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imagenPlaceholder() {
    return Container(
      color: TemaPersona5.surfaceColor,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: TemaPersona5.textSecondary),
      ),
    );
  }

  Widget _seccionInfo(IconData icono, String titulo, String contenido) {
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

  Widget _seccionHorarios(List<String> horarios) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time, color: TemaPersona5.primaryColor, size: 24),
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
                ...horarios.map((dia) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        dia,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: TemaPersona5.textSecondary,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

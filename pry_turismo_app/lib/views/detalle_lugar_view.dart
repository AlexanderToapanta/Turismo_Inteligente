import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/turismo_viewmodel.dart';
import '../models/sitio_turistico.dart';

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
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color(0xFF0D7377),
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0D7377),
                              ),
                            ),
                          ),
                          if (detalle != null && detalle.rating > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    detalle.rating.toString(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
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
                          color: Colors.grey[600],
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
                          icon: const Icon(Icons.directions),
                          label: const Text('Navegar hacia acá'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D7377),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Indicador de carga
                      if (cargando)
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
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
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
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
                                    borderRadius: BorderRadius.circular(12),
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
                                Icon(Icons.info_outline, color: Colors.grey[400], size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  'Información detallada no disponible',
                                  style: GoogleFonts.poppins(color: Colors.grey[600]),
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
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _seccionInfo(IconData icono, String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: const Color(0xFF0D7377), size: 24),
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
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contenido,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
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
          const Icon(Icons.access_time, color: Color(0xFF0D7377), size: 24),
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
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                ...horarios.map((dia) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        dia,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
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

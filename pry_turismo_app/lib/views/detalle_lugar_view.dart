import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/turismo_viewmodel.dart';
import '../viewmodels/resena_viewmodel.dart';
import '../models/sitio_turistico.dart';
import '../theme/tema_turismo.dart';

import 'crear_resena_view.dart';
import 'widgets/promedio_resenas_widget.dart';
import 'widgets/promedio_resenas_sugerencia_widget.dart';
import 'widgets/imagen_placeholder_widget.dart';
import 'widgets/seccion_info_widget.dart';
import 'widgets/seccion_horarios_widget.dart';

class DetalleLugarView extends StatefulWidget {
  final SitioTuristico sitio;

  const DetalleLugarView({super.key, required this.sitio});

  @override
  State<DetalleLugarView> createState() => _DetalleLugarViewState();
}

class _DetalleLugarViewState extends State<DetalleLugarView> {
  String? _direccion;
  bool _cargandoDireccion = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TurismoViewModel>(
        context,
        listen: false,
      ).cargarDetallesLugar(widget.sitio);
    });

    if (widget.sitio.esSugerencia) {
      _obtenerDireccion();
    }
  }

  Future<void> _obtenerDireccion() async {
    setState(() => _cargandoDireccion = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=${widget.sitio.latitud}'
        '&lon=${widget.sitio.longitud}'
        '&accept-language=es',
      );

      final response = await http
          .get(url, headers: {'User-Agent': 'TurismoApp/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;

        setState(() {
          _direccion = data['display_name'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Error obteniendo dirección: $e');
    } finally {
      if (mounted) {
        setState(() => _cargandoDireccion = false);
      }
    }
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
                  background: _buildImagenPrincipal(viewModel, detalle),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: TemaPersona5.secondaryColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTituloYRating(detalle),

                      const SizedBox(height: 8),

                      PromedioResenasWidget(
                        cargandoPromedio: viewModel.cargandoPromedio,
                        promedioResenas: viewModel.promedioResenas,
                      ),

                      Text(
                        widget.sitio.categoria,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: TemaPersona5.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildBotonNavegar(viewModel),

                      const SizedBox(height: 24),

                      if (cargando)
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              TemaPersona5.primaryColor,
                            ),
                          ),
                        ),

                      if (widget.sitio.esSugerencia)
                        _buildDetallesSugerencia(viewModel)
                      else if (!cargando && detalle != null)
                        _buildDetallesGoogle(viewModel, detalle),

                      if (!cargando &&
                          detalle == null &&
                          !widget.sitio.esSugerencia)
                        _buildSinInformacion(),
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

  Widget _buildImagenPrincipal(TurismoViewModel viewModel, dynamic detalle) {
    if (widget.sitio.esSugerencia) {
      if (widget.sitio.imagenUrl.isNotEmpty) {
        return Image.network(
          widget.sitio.imagenUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const ImagenPlaceholderWidget(),
        );
      }

      return const ImagenPlaceholderWidget();
    }

    if (detalle != null && detalle.fotos.isNotEmpty) {
      return Image.network(
        viewModel.placesService.obtenerUrlFoto(detalle.fotos.first),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const ImagenPlaceholderWidget(),
      );
    }

    return Image.network(
      widget.sitio.imagenUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const ImagenPlaceholderWidget(),
    );
  }

  Widget _buildTituloYRating(dynamic detalle) {
    return Row(
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

        if (widget.sitio.esSugerencia)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade600),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_border, color: Colors.grey.shade400, size: 14),
                const SizedBox(width: 3),
                Text(
                  'Sin puntuación de Google',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          )
        else if (detalle != null && detalle.rating > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TemaPersona5.secondaryColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: TemaPersona5.primaryColor, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: TemaPersona5.primaryColor,
                  size: 14,
                ),
                const SizedBox(width: 3),
                Text(
                  detalle.rating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: TemaPersona5.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'Google',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: TemaPersona5.primaryColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBotonNavegar(TurismoViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              viewModel.trazarRuta(widget.sitio);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.directions, color: TemaPersona5.secondaryColor),
            label: const Text(
              'Navegar hacia acá',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaPersona5.primaryColor,
              foregroundColor: TemaPersona5.secondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Pre-seleccionar el lugar en el ViewModel de reseñas
              final resenaVM = Provider.of<ResenaViewModel>(context, listen: false);
              resenaVM.seleccionarLugar(widget.sitio);
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CrearResenaView()),
              );
            },
            icon: const Icon(Icons.rate_review, color: TemaPersona5.primaryColor),
            label: const Text(
              'Escribir una reseña',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: TemaPersona5.primaryColor, width: 2),
              foregroundColor: TemaPersona5.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetallesSugerencia(TurismoViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PromedioResenasSugerenciaWidget(
          cargandoPromedio: viewModel.cargandoPromedio,
          promedioResenas: viewModel.promedioResenas,
        ),

        const SizedBox(height: 16),

        SeccionInfoWidget(
          icono: Icons.access_time,
          titulo: 'Horario de Atención',
          contenido: widget.sitio.horario ?? 'No especificado',
        ),

        if (_cargandoDireccion)
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TemaPersona5.primaryColor,
                  ),
                ),
                SizedBox(width: 12),
                Text('Obteniendo dirección...'),
              ],
            ),
          )
        else
          SeccionInfoWidget(
            icono: Icons.location_on,
            titulo: 'Dirección',
            contenido:
                _direccion ??
                'Lat: ${widget.sitio.latitud.toStringAsFixed(4)}, '
                    'Lng: ${widget.sitio.longitud.toStringAsFixed(4)}',
          ),

        const SeccionInfoWidget(
          icono: Icons.people,
          titulo: 'Origen',
          contenido: 'Sugerido por la comunidad',
        ),
      ],
    );
  }

  Widget _buildDetallesGoogle(TurismoViewModel viewModel, dynamic detalle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeccionInfoWidget(
          icono: Icons.location_on,
          titulo: 'Dirección',
          contenido: detalle.direccionCompleta,
        ),

        if (detalle.telefono != 'No disponible')
          SeccionInfoWidget(
            icono: Icons.phone,
            titulo: 'Teléfono',
            contenido: detalle.telefono,
          ),

        if (detalle.sitioWeb != 'No disponible')
          SeccionInfoWidget(
            icono: Icons.language,
            titulo: 'Sitio Web',
            contenido: detalle.sitioWeb,
          ),

        if (detalle.horarios.isNotEmpty)
          SeccionHorariosWidget(horarios: detalle.horarios),

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
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      viewModel.placesService.obtenerUrlFoto(
                        detalle.fotos[i + 1],
                      ),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ImagenPlaceholderWidget(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSinInformacion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: TemaPersona5.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Información detallada no disponible',
              style: GoogleFonts.poppins(color: TemaPersona5.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/turismo_viewmodel.dart';
import 'detalle_lugar_view.dart';

class MapaView extends StatelessWidget {
  const MapaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TurismoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.posicionActual == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
            ),
          );
        }

        final miPosicion = LatLng(
          viewModel.posicionActual!.latitude,
          viewModel.posicionActual!.longitude,
        );

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: miPosicion,
                initialZoom: 15,
              ),
              children: [
                // Capa de Mapa
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pry_turismo_app',
                ),
                
                // Capa de la Ruta
                if (viewModel.puntosRuta.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: viewModel.puntosRuta,
                        color: const Color(0xFF0D7377),
                        strokeWidth: 5.0,
                        borderStrokeWidth: 2.0,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),

                // Capa de Marcadores
                MarkerLayer(
                  markers: [
                    // Marcador del Usuario
                    Marker(
                      point: miPosicion,
                      width: 45,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 45,
                        ),
                      ),
                    ),
                    // Marcadores de Sitios
                    ...viewModel.sitiosFiltrados.map((sitio) {
                      final esSitioSeleccionado =
                          viewModel.sitioSeleccionado?.nombre == sitio.nombre;
                      return Marker(
                        point: LatLng(sitio.latitud, sitio.longitud),
                        width: esSitioSeleccionado ? 60 : 50,
                        height: esSitioSeleccionado ? 60 : 50,
                        child: GestureDetector(
                          onTap: () => _mostrarDetalleSitio(
                            context,
                            viewModel,
                            sitio,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (esSitioSeleccionado)
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              Icon(
                                Icons.location_on,
                                color: esSitioSeleccionado
                                    ? Colors.orange
                                    : Colors.red,
                                size: esSitioSeleccionado ? 45 : 35,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

            // Indicador de carga
            if (viewModel.cargando)
              const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
                ),
              ),

            // Información superior con filtros
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explora tu entorno',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0D7377),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${viewModel.sitiosFiltrados.length} resultados encontrados',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D7377).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.explore_outlined,
                            color: Color(0xFF0D7377),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Lista horizontal de categorías
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.categorias.length,
                      itemBuilder: (context, index) {
                        final categoria = viewModel.categorias[index];
                        final isSelected = viewModel.categoriaSeleccionada == categoria;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              categoria,
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : const Color(0xFF0D7377),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                viewModel.cambiarCategoria(categoria);
                              }
                            },
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF0D7377),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : const Color(0xFF0D7377).withOpacity(0.5),
                              ),
                            ),
                            elevation: isSelected ? 4 : 2,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Botón para limpiar ruta
            if (viewModel.sitioSeleccionado != null)
              Positioned(
                bottom: 90,
                right: 20,
                child: FloatingActionButton.extended(
                  onPressed: () => viewModel.limpiarRuta(),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.close),
                  label: const Text('Limpiar'),
                ),
              ),

            // Indicador de sitio seleccionado
            if (viewModel.sitioSeleccionado != null)
              Positioned(
                bottom: 90,
                left: 20,
                right: 140,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D7377),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Navegando hacia:',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.sitioSeleccionado!.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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



  void _mostrarDetalleSitio(
    BuildContext context,
    TurismoViewModel vm,
    dynamic sitio,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre
              Text(
                sitio.nombre,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0D7377),
                ),
              ),
              const SizedBox(height: 12),
              // Descripción
              Text(
                sitio.descripcion,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              // Información en dos columnas
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distancia',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D7377).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            vm.formatearDistancia(vm.obtenerDistancia(sitio)),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0D7377),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dirección',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA500).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            vm.obtenerDireccionCardinal(sitio),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFFA500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar el bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleLugarView(sitio: sitio),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Detalles'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0D7377),
                        side: const BorderSide(color: Color(0xFF0D7377)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        vm.trazarRuta(sitio);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Navegar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D7377),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
}

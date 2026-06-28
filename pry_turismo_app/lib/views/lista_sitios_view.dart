import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/turismo_viewmodel.dart';
import 'detalle_lugar_view.dart';
import '../theme/tema_turismo.dart';

class ListaSitiosView extends StatelessWidget {
  const ListaSitiosView({super.key});

  @override
  Widget build(BuildContext context) {
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
                childAspectRatio: 0.75, // Ajustar la relación de aspecto para que quepa la información
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final sitio = viewModel.sitiosFiltrados[index];
                final distancia = viewModel.obtenerDistancia(sitio);
                final direccion = viewModel.obtenerDireccionCardinal(sitio);

                return Card(
                  // El Card Theme ya está configurado en TemaPersona5 (borde rojo, fondo oscuro)
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
                        // Imagen
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            child: Image.network(
                              sitio.imagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: TemaPersona5.surfaceColor,
                                    child: const Icon(Icons.image_not_supported, color: TemaPersona5.textSecondary),
                                  ),
                            ),
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
                                    fontSize: 20,
                                    color: TemaPersona5.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sitio.descripcion,
                                  maxLines: 1,
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

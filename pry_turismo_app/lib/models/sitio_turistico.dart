class SitioTuristico {
  final String nombre;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String imagenUrl;

  SitioTuristico({
    required this.nombre,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.imagenUrl,
  });

  // Obtener dirección cardinal desde coordenadas
  String getDireccionCardinal() {
    // Para un mayor detalle, podrías agregar una API de geocodificación inversa
    return "Ubicación: $latitud, $longitud";
  }
}

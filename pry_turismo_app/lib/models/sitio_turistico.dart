class SitioTuristico {
  final String nombre;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String imagenUrl;
  final String categoria;
  // Campos extra para sugerencias aprobadas de Firebase
  final bool esSugerencia;
  final String? horario;
  final String? sugerenciaId;

  SitioTuristico({
    required this.nombre,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.imagenUrl,
    this.categoria = 'Otro',
    this.esSugerencia = false,
    this.horario,
    this.sugerenciaId,
  });

  // Obtener dirección cardinal desde coordenadas
  String getDireccionCardinal() {
    // Para un mayor detalle, podrías agregar una API de geocodificación inversa
    return "Ubicación: $latitud, $longitud";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SitioTuristico &&
      other.nombre == nombre &&
      other.latitud == latitud &&
      other.longitud == longitud &&
      other.categoria == categoria;
  }

  @override
  int get hashCode {
    return nombre.hashCode ^
      latitud.hashCode ^
      longitud.hashCode ^
      categoria.hashCode;
  }
}

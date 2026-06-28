class DetalleLugar {
  final double rating;
  final List<String> fotos; // Referencias a fotos de Google Places o URLs
  final List<String> horarios;
  final String telefono;
  final String sitioWeb;
  final String direccionCompleta;

  DetalleLugar({
    required this.rating,
    required this.fotos,
    required this.horarios,
    required this.telefono,
    required this.sitioWeb,
    required this.direccionCompleta,
  });

  factory DetalleLugar.fromJson(Map<String, dynamic> json) {
    // Las respuestas de Google Places pueden no tener todos los campos
    
    // Extraer rating
    final rating = (json['rating'] ?? 0.0).toDouble();

    // Extraer fotos
    List<String> fotosList = [];
    if (json['photos'] != null) {
      for (var photo in json['photos']) {
        if (photo['photo_reference'] != null) {
          fotosList.add(photo['photo_reference']);
        }
      }
    }

    // Extraer horarios
    List<String> horariosList = [];
    if (json['opening_hours'] != null && json['opening_hours']['weekday_text'] != null) {
      for (var day in json['opening_hours']['weekday_text']) {
        horariosList.add(day.toString());
      }
    }

    return DetalleLugar(
      rating: rating,
      fotos: fotosList,
      horarios: horariosList,
      telefono: json['formatted_phone_number'] ?? 'No disponible',
      sitioWeb: json['website'] ?? 'No disponible',
      direccionCompleta: json['formatted_address'] ?? 'Dirección no disponible',
    );
  }
}

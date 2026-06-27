/// Modelo liviano para representar un lugar de la colección "lugares"
/// en el dropdown del formulario de reseñas.
class LugarModel {
  final String id;
  final String nombre;

  const LugarModel({required this.id, required this.nombre});

  factory LugarModel.fromMap(Map<String, dynamic> map, String docId) {
    return LugarModel(
      id: docId,
      nombre: map['nombre'] as String? ?? 'Sin nombre',
    );
  }
}

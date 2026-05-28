class Categoria {
  final String id;
  final String nombre;
  final String descripcion;
  final String? imagen;

  Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.imagen,
  });

  factory Categoria.fromFirestore(Map<String, dynamic> data, String id) {
    return Categoria(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      imagen: data['imagen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': imagen,
    };
  }
}

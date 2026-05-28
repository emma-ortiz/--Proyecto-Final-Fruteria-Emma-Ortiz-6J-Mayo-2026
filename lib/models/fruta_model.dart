class Fruta {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String imagen;
  final double precio;
  final int stock;
  final bool disponible;

  Fruta({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.imagen,
    required this.precio,
    this.stock = 0,
    this.disponible = true,
  });

  factory Fruta.fromFirestore(Map<String, dynamic> data, String id) {
    return Fruta(
      id: id,
      nombre: data['nombre'] ?? '',
      categoria: data['categoria'] ?? '',
      descripcion: data['descripcion'] ?? '',
      imagen: data['imagen'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      disponible: data['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoria': categoria,
      'descripcion': descripcion,
      'imagen': imagen,
      'precio': precio,
      'stock': stock,
      'disponible': disponible,
    };
  }
}

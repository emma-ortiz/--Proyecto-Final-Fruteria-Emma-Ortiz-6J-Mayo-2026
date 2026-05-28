class ItemCarrito {
  final String productoId;
  final String nombre;
  final double precioUnitario;
  int cantidad;
  final String? imagen;

  ItemCarrito({
    required this.productoId,
    required this.nombre,
    required this.precioUnitario,
    this.cantidad = 1,
    this.imagen,
  });

  double get subtotal => precioUnitario * cantidad;

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
      'imagen': imagen,
    };
  }

  factory ItemCarrito.fromMap(Map<String, dynamic> data) {
    return ItemCarrito(
      productoId: data['productoId'] ?? '',
      nombre: data['nombre'] ?? '',
      precioUnitario: (data['precioUnitario'] ?? 0).toDouble(),
      cantidad: data['cantidad'] ?? 1,
      imagen: data['imagen'],
    );
  }
}

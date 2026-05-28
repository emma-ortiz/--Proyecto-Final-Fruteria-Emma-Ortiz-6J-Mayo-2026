class Oferta {
  final String id;
  final String productoId;
  final String productoNombre;
  final double descuento;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? imagen;

  Oferta({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.descuento,
    required this.fechaInicio,
    required this.fechaFin,
    this.imagen,
  });

  factory Oferta.fromFirestore(Map<String, dynamic> data, String id) {
    return Oferta(
      id: id,
      productoId: data['productoId'] ?? '',
      productoNombre: data['productoNombre'] ?? '',
      descuento: (data['descuento'] ?? 0).toDouble(),
      fechaInicio: (data['fechaInicio'] as dynamic).toDate(),
      fechaFin: (data['fechaFin'] as dynamic).toDate(),
      imagen: data['imagen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'productoNombre': productoNombre,
      'descuento': descuento,
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'imagen': imagen,
    };
  }
}

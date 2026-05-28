import 'package:olivos_verdes/models/carrito_model.dart';

class Pedido {
  final String id;
  final String idUsuario;
  final String nombreUsuario;
  final List<ItemCarrito> productos;
  final double total;
  final String estado;
  final DateTime fecha;
  final String? direccionEntrega;

  Pedido({
    required this.id,
    required this.idUsuario,
    this.nombreUsuario = '',
    required this.productos,
    required this.total,
    required this.estado,
    required this.fecha,
    this.direccionEntrega,
  });

  factory Pedido.fromFirestore(Map<String, dynamic> data, String id) {
    var listaProductos = (data['productos'] as List)
        .map((item) => ItemCarrito.fromMap(item as Map<String, dynamic>))
        .toList();

    return Pedido(
      id: id,
      idUsuario: data['idUsuario'] ?? '',
      nombreUsuario: data['nombreUsuario'] ?? '',
      productos: listaProductos,
      total: (data['total'] ?? 0).toDouble(),
      estado: data['estado'] ?? 'pendiente',
      fecha: data['fecha'] != null
          ? (data['fecha'] as dynamic).toDate()
          : DateTime.now(),
      direccionEntrega: data['direccionEntrega'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'nombreUsuario': nombreUsuario,
      'productos': productos.map((p) => p.toMap()).toList(),
      'total': total,
      'estado': estado,
      'fecha': fecha,
      'direccionEntrega': direccionEntrega,
    };
  }
}

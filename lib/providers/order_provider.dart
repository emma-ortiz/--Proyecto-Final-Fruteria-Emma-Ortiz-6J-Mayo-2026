import 'package:flutter/material.dart';
import 'package:olivos_verdes/models/pedido_model.dart';
import 'package:olivos_verdes/models/carrito_model.dart';
import 'package:olivos_verdes/services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Pedido> _pedidos = [];
  bool _loading = true;

  List<Pedido> get pedidos => _pedidos;
  bool get loading => _loading;

  void cargarPedidos(String uid) {
    _firestoreService.pedidosUsuario(uid).listen((pedidos) {
      _pedidos = pedidos;
      _loading = false;
      notifyListeners();
    });
  }

  void cargarTodosPedidos() {
    _firestoreService.pedidosStream.listen((pedidos) {
      _pedidos = pedidos;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> crearPedido({
    required String idUsuario,
    required String nombreUsuario,
    required List<ItemCarrito> productos,
    required double total,
    String? direccionEntrega,
  }) async {
    final pedido = Pedido(
      id: '',
      idUsuario: idUsuario,
      nombreUsuario: nombreUsuario,
      productos: productos,
      total: total,
      estado: 'pendiente',
      fecha: DateTime.now(),
      direccionEntrega: direccionEntrega,
    );
    await _firestoreService.crearPedido(pedido);
  }

  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    await _firestoreService.actualizarPedido(id, {'estado': nuevoEstado});
  }

  String get estadoLabel {
    if (_pedidos.isEmpty) return 'Sin pedidos';
    return '${_pedidos.length} pedidos';
  }
}

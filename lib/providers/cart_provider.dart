import 'package:flutter/material.dart';
import 'package:olivos_verdes/models/carrito_model.dart';

class CartProvider extends ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  void agregarItem(
    String productoId,
    String nombre,
    double precio, {
    String? imagen,
    int cantidad = 1,
  }) {
    final index = _items.indexWhere((i) => i.productoId == productoId);
    if (index >= 0) {
      _items[index].cantidad += cantidad;
    } else {
      _items.add(ItemCarrito(
        productoId: productoId,
        nombre: nombre,
        precioUnitario: precio,
        cantidad: cantidad,
        imagen: imagen,
      ));
    }
    notifyListeners();
  }

  void eliminarItem(String productoId) {
    _items.removeWhere((i) => i.productoId == productoId);
    notifyListeners();
  }

  void actualizarCantidad(String productoId, int cantidad) {
    final index = _items.indexWhere((i) => i.productoId == productoId);
    if (index >= 0) {
      if (cantidad <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].cantidad = cantidad;
      }
      notifyListeners();
    }
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:olivos_verdes/models/fruta_model.dart';
import 'package:olivos_verdes/services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Fruta> _frutas = [];
  List<Fruta> _destacadas = [];
  bool _loading = true;

  List<Fruta> get frutas => _frutas;
  List<Fruta> get destacadas => _destacadas;
  bool get loading => _loading;

  ProductProvider() {
    _firestoreService.frutasStream.listen((frutas) {
      _frutas = frutas;
      _loading = false;
      notifyListeners();
    });

    _firestoreService.frutasDestacadas().listen((destacadas) {
      _destacadas = destacadas;
      notifyListeners();
    });
  }

  List<Fruta> filtrarPorCategoria(String categoriaId) {
    return _frutas.where((f) => f.categoria == categoriaId).toList();
  }

  List<Fruta> buscar(String query) {
    if (query.isEmpty) return _frutas;
    return _frutas
        .where((f) => f.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Fruta? obtenerPorId(String id) {
    try {
      return _frutas.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> agregarFruta(Fruta fruta) async {
    await _firestoreService.crearFruta(fruta);
  }

  Future<void> actualizarFruta(String id, Map<String, dynamic> data) async {
    await _firestoreService.actualizarFruta(id, data);
  }

  Future<void> eliminarFruta(String id) async {
    await _firestoreService.eliminarFruta(id);
  }
}

import 'package:flutter/material.dart';
import 'package:olivos_verdes/models/categoria_model.dart';
import 'package:olivos_verdes/services/firestore_service.dart';

class CategoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Categoria> _categorias = [];
  bool _loading = true;

  List<Categoria> get categorias => _categorias;
  bool get loading => _loading;

  CategoryProvider() {
    _firestoreService.categoriasStream.listen((categorias) {
      _categorias = categorias;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> agregarCategoria(Categoria categoria) async {
    await _firestoreService.crearCategoria(categoria);
  }

  Future<void> actualizarCategoria(String id, Map<String, dynamic> data) async {
    await _firestoreService.actualizarCategoria(id, data);
  }

  Future<void> eliminarCategoria(String id) async {
    await _firestoreService.eliminarCategoria(id);
  }
}

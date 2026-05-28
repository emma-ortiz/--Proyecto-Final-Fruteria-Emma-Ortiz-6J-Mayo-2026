import 'package:flutter/material.dart';
import 'package:olivos_verdes/models/oferta_model.dart';
import 'package:olivos_verdes/services/firestore_service.dart';

class OfferProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Oferta> _ofertas = [];
  bool _loading = true;

  List<Oferta> get ofertas => _ofertas;
  List<Oferta> get activas {
    final now = DateTime.now();
    return _ofertas.where((o) => o.fechaInicio.isBefore(now) && o.fechaFin.isAfter(now)).toList();
  }

  bool get loading => _loading;

  OfferProvider() {
    _firestoreService.ofertasStream.listen((ofertas) {
      _ofertas = ofertas;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> agregarOferta(Oferta oferta) async {
    await _firestoreService.crearOferta(oferta);
  }

  Future<void> actualizarOferta(String id, Map<String, dynamic> data) async {
    await _firestoreService.actualizarOferta(id, data);
  }

  Future<void> eliminarOferta(String id) async {
    await _firestoreService.eliminarOferta(id);
  }
}

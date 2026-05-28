import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olivos_verdes/models/fruta_model.dart';
import 'package:olivos_verdes/models/categoria_model.dart';
import 'package:olivos_verdes/models/pedido_model.dart';
import 'package:olivos_verdes/models/oferta_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _frutas => _db.collection('frutas');
  CollectionReference<Map<String, dynamic>> get _categorias => _db.collection('categorias');
  CollectionReference<Map<String, dynamic>> get _pedidos => _db.collection('pedidos');
  CollectionReference<Map<String, dynamic>> get _ofertas => _db.collection('ofertas');

  Stream<List<Fruta>> get frutasStream {
    return _frutas.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Fruta.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Categoria>> get categoriasStream {
    return _categorias.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Categoria.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Oferta>> get ofertasStream {
    return _ofertas.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Oferta.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Pedido>> pedidosUsuario(String uid) {
    return _pedidos
        .where('idUsuario', isEqualTo: uid)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Pedido.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Pedido>> get pedidosStream {
    return _pedidos.orderBy('fecha', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Pedido.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Fruta>> frutasPorCategoria(String categoriaId) {
    return _frutas.where('categoria', isEqualTo: categoriaId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Fruta.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<Fruta>> frutasDestacadas() {
    return _frutas.where('disponible', isEqualTo: true).limit(6).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Fruta.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> crearFruta(Fruta fruta) async {
    await _frutas.add(fruta.toMap());
  }

  Future<void> actualizarFruta(String id, Map<String, dynamic> data) async {
    await _frutas.doc(id).update(data);
  }

  Future<void> eliminarFruta(String id) async {
    await _frutas.doc(id).delete();
  }

  Future<void> crearCategoria(Categoria categoria) async {
    await _categorias.add(categoria.toMap());
  }

  Future<void> actualizarCategoria(String id, Map<String, dynamic> data) async {
    await _categorias.doc(id).update(data);
  }

  Future<void> eliminarCategoria(String id) async {
    await _categorias.doc(id).delete();
  }

  Future<void> crearOferta(Oferta oferta) async {
    await _ofertas.add(oferta.toMap());
  }

  Future<void> actualizarOferta(String id, Map<String, dynamic> data) async {
    await _ofertas.doc(id).update(data);
  }

  Future<void> eliminarOferta(String id) async {
    await _ofertas.doc(id).delete();
  }

  Future<void> crearPedido(Pedido pedido) async {
    await _pedidos.add(pedido.toMap());
  }

  Future<void> actualizarPedido(String id, Map<String, dynamic> data) async {
    await _pedidos.doc(id).update(data);
  }

  Future<int> contarPedidos(String estado) async {
    final snapshot = await _pedidos.where('estado', isEqualTo: estado).get();
    return snapshot.docs.length;
  }

  Future<int> contarProductos() async {
    final snapshot = await _frutas.get();
    return snapshot.docs.length;
  }
}

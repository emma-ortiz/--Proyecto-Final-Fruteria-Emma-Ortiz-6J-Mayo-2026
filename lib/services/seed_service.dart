import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> hayAdmins() async {
    final admins = await _db.collection('usuarios').where('rol', isEqualTo: 'admin').limit(1).get();
    return admins.docs.isNotEmpty;
  }

  Future<void> hacerAdmin(String uid) async {
    await _db.collection('usuarios').doc(uid).update({'rol': 'admin'});
  }

  Future<void> cargarDatosPrueba() async {
    final existentes = await _db.collection('categorias').limit(1).get();
    if (existentes.docs.isNotEmpty) return;
    await _cargarCategorias();
    await _cargarFrutas();
    await _cargarOfertas();
  }

  Future<void> _cargarCategorias() async {
    final categorias = [
      {'nombre': 'Tropicales', 'descripcion': 'Frutas exóticas y tropicales', 'imagen': ''},
      {'nombre': 'Cítricos', 'descripcion': 'Frutas ácidas y refrescantes', 'imagen': ''},
      {'nombre': 'De Temporada', 'descripcion': 'Las mejores frutas de la temporada', 'imagen': ''},
      {'nombre': 'Bayas', 'descripcion': 'Pequeñas frutas llenas de sabor', 'imagen': ''},
      {'nombre': 'Deshidratadas', 'descripcion': 'Frutas secas y snacks saludables', 'imagen': ''},
    ];

    for (final cat in categorias) {
      await _db.collection('categorias').add(cat);
    }
  }

  Future<void> _cargarFrutas() async {
    final categorias = await _db.collection('categorias').get();
    if (categorias.docs.isEmpty) return;

    final catMap = <String, String>{};
    for (final doc in categorias.docs) {
      catMap[doc.data()['nombre']] = doc.id;
    }

    final frutas = [
      {'nombre': 'Mango', 'categoria': catMap['Tropicales'] ?? '', 'descripcion': 'Mango fresco y dulce, ideal para jugos y postres.', 'imagen': 'https://raw.githubusercontent.com/emma-ortiz/imagenes-flutter/main/mango.jpg', 'precio': 25.50, 'stock': 50, 'disponible': true},
      {'nombre': 'Piña', 'categoria': catMap['Tropicales'] ?? '', 'descripcion': 'Piña golden dulce y jugosa.', 'imagen': 'https://raw.githubusercontent.com/emma-ortiz/imagenes-flutter/main/pina.jpg', 'precio': 35.00, 'stock': 30, 'disponible': true},
      {'nombre': 'Papaya', 'categoria': catMap['Tropicales'] ?? '', 'descripcion': 'Papaya maradol lista para comer.', 'imagen': 'https://raw.githubusercontent.com/emma-ortiz/imagenes-flutter/main/papaya.jpg', 'precio': 28.00, 'stock': 20, 'disponible': true},
      {'nombre': 'Naranja', 'categoria': catMap['Cítricos'] ?? '', 'descripcion': 'Naranja jugosa, rica en vitamina C.', 'imagen': 'https://raw.githubusercontent.com/emma-ortiz/imagenes-flutter/main/naranja.jpg', 'precio': 15.00, 'stock': 100, 'disponible': true},
      {'nombre': 'Limón', 'categoria': catMap['Cítricos'] ?? '', 'descripcion': 'Limón agrio, perfecto para cocina y bebidas.', 'imagen': 'https://raw.githubusercontent.com/emma-ortiz/imagenes-flutter/main/limon.jpg', 'precio': 12.50, 'stock': 80, 'disponible': true},
      {'nombre': 'Toronja', 'categoria': catMap['Cítricos'] ?? '', 'descripcion': 'Toronja rosada, refrescante y ligeramente ácida.', 'imagen': '', 'precio': 22.00, 'stock': 25, 'disponible': true},
      {'nombre': 'Fresa', 'categoria': catMap['Bayas'] ?? '', 'descripcion': 'Fresas frescas, dulces y aromáticas.', 'imagen': 'https://raw.githubusercontent.com/emma-ortiz/imagenes-flutter/main/fresa.jpg', 'precio': 45.00, 'stock': 40, 'disponible': true},
      {'nombre': 'Arándano', 'categoria': catMap['Bayas'] ?? '', 'descripcion': 'Arándanos azules, ricos en antioxidantes.', 'imagen': '', 'precio': 65.00, 'stock': 15, 'disponible': true},
      {'nombre': 'Uva', 'categoria': catMap['Bayas'] ?? '', 'descripcion': 'Uva verde sin semilla, dulce y crujiente.', 'imagen': '', 'precio': 38.00, 'stock': 35, 'disponible': true},
      {'nombre': 'Manzana', 'categoria': catMap['De Temporada'] ?? '', 'descripcion': 'Manzana roja, jugosa y crujiente.', 'imagen': 'https://raw.githubusercontent.com/emma-ortiz/imagenes-flutter/main/manzana.jpg', 'precio': 18.00, 'stock': 60, 'disponible': true},
      {'nombre': 'Pera', 'categoria': catMap['De Temporada'] ?? '', 'descripcion': 'Pera verde, dulce y suave.', 'imagen': '', 'precio': 22.00, 'stock': 25, 'disponible': true},
      {'nombre': 'Plátano', 'categoria': catMap['De Temporada'] ?? '', 'descripcion': 'Plátano tabasco, dulce y energético.', 'imagen': '', 'precio': 10.00, 'stock': 120, 'disponible': true},
      {'nombre': 'Ciruela Pasa', 'categoria': catMap['Deshidratadas'] ?? '', 'descripcion': 'Ciruela pasa, fibra natural y dulce.', 'imagen': '', 'precio': 55.00, 'stock': 20, 'disponible': true},
      {'nombre': 'Dátil', 'categoria': catMap['Deshidratadas'] ?? '', 'descripcion': 'Dátiles medjool, dulces y suaves.', 'imagen': '', 'precio': 85.00, 'stock': 10, 'disponible': true},
    ];

    for (final fruta in frutas) {
      await _db.collection('frutas').add(fruta);
    }
  }

  Future<void> _cargarOfertas() async {
    final frutas = await _db.collection('frutas').limit(10).get();
    if (frutas.docs.isEmpty) return;

    if (frutas.docs.length >= 2) {
      await _db.collection('ofertas').add({
        'productoId': frutas.docs[0].id,
        'productoNombre': frutas.docs[0].data()['nombre'],
        'descuento': 20,
        'fechaInicio': DateTime.now().subtract(const Duration(days: 1)),
        'fechaFin': DateTime.now().add(const Duration(days: 15)),
        'imagen': '',
      });

      await _db.collection('ofertas').add({
        'productoId': frutas.docs[1].id,
        'productoNombre': frutas.docs[1].data()['nombre'],
        'descuento': 35,
        'fechaInicio': DateTime.now().subtract(const Duration(days: 3)),
        'fechaFin': DateTime.now().add(const Duration(days: 7)),
        'imagen': '',
      });
    }
  }
}

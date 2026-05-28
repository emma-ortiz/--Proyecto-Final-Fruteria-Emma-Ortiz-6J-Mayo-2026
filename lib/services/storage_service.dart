import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> subirImagen(String path, XFile file) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putData(await file.readAsBytes());
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> eliminarImagen(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}

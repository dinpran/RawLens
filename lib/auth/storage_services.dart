import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  // specify your storage directory
  final String? uid;
  StorageService({this.uid});
  Future<List<String>> listAllImages() async {
    final String storageDirectory = 'users/${uid}/profilepic';
    List<String> imageUrls = [];

    try {
      ListResult result = await _firebaseStorage.ref(storageDirectory).list();
      for (var item in result.items) {
        String imageUrl = await item.getDownloadURL();
        imageUrls.add(imageUrl);
      }
    } catch (e) {
      print("Error listing images: $e");
    }

    return imageUrls;
  }
}

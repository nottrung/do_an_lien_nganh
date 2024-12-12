import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageHelper {
  static FirebaseStorageHelper instance = FirebaseStorageHelper();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserImage(File image) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    TaskSnapshot taskSnapshot =
        await _storage.ref('users/${userId}').putFile(image);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<String> uploadCategoryImage(String categoryId, File image) async {
    TaskSnapshot taskSnapshot =
        await _storage.ref('categories/${categoryId}').putFile(image);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<String> uploadProductImage(String productId, File image) async {
    TaskSnapshot taskSnapshot =
    await _storage.ref('products/${productId}').putFile(image);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }
}

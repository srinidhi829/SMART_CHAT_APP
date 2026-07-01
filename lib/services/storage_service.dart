import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage storage =
      FirebaseStorage.instance;

  final ImagePicker picker = ImagePicker();

  Future<File?> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return null;

    return File(image.path);
  }

  Future<String> uploadProfileImage({
    required String uid,
    required File image,
  }) async {
    final ref = storage
        .ref()
        .child("profile_images")
        .child("$uid.jpg");

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }
  Future<String> uploadChatImage({
    required File image,
  }) async {
    final fileName =
    DateTime.now().millisecondsSinceEpoch.toString();

    final ref = storage
        .ref()
        .child("chat_images")
        .child("$fileName.jpg");

    await ref.putFile(image);

    return await ref.getDownloadURL();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "name": name,
      "email": email,
      "phone": phone,
      "profileImage": "",
      "about": "Hey there! I'm using Smart Chat.",
      "isOnline": true,
      "lastSeen": FieldValue.serverTimestamp(),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
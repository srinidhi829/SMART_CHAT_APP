import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStatusService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  Future<void> setOnline() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) return;

    await firestore
        .collection("users")
        .doc(uid)
        .update({
      "isOnline": true,
      "lastSeen": FieldValue.serverTimestamp(),
    });
  }

  Future<void> setOffline() async {
    final uid = auth.currentUser?.uid;

    if (uid == null) return;

    await firestore
        .collection("users")
        .doc(uid)
        .update({
      "isOnline": false,
      "lastSeen": FieldValue.serverTimestamp(),
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';

class GroupService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  //-----------------------------------------------------

  Future<void> createGroup({
    required String groupName,
    required List<String> members,
  }) async {
    final adminId = auth.currentUser!.uid;

    final doc = firestore.collection("groups").doc();

    final group = GroupModel(
      groupId: doc.id,
      groupName: groupName,
      adminId: adminId,
      groupImage: "",
      members: [
        adminId,
        ...members,
      ],
      createdAt: Timestamp.now(),
    );

    await doc.set(group.toMap());
  }

  //-----------------------------------------------------

  Stream<QuerySnapshot> getGroups() {
    final uid = auth.currentUser!.uid;

    return firestore
        .collection("groups")
        .where("members", arrayContains: uid)
        //.orderBy("createdAt", descending: true)
        .snapshots();
  }

  //-----------------------------------------------------

  Future<void> sendGroupMessage({
    required String groupId,
    required String message,
  }) async {
    await firestore
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .add({
      "senderId": auth.currentUser!.uid,
      "message": message,
      "timestamp": FieldValue.serverTimestamp(),
      "type": "text",
    });
  }

  //-----------------------------------------------------

  Stream<QuerySnapshot> getGroupMessages(
      String groupId) {
    return firestore
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .orderBy("timestamp")
        .snapshots();
  }

  //-----------------------------------------------------

  Future<void> addMember({
    required String groupId,
    required String uid,
  }) async {
    await firestore
        .collection("groups")
        .doc(groupId)
        .update({
      "members": FieldValue.arrayUnion([uid]),
    });
  }

  //-----------------------------------------------------

  Future<void> removeMember({
    required String groupId,
    required String uid,
  }) async {
    await firestore
        .collection("groups")
        .doc(groupId)
        .update({
      "members": FieldValue.arrayRemove([uid]),
    });
  }

  //-----------------------------------------------------

  Future<void> deleteGroup(
      String groupId) async {
    await firestore
        .collection("groups")
        .doc(groupId)
        .delete();
  }
}
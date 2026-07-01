import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join("_");
  }
  Future<void> updateTypingStatus({
    required String receiverId,
    required bool isTyping,
  }) async {
    final senderId = auth.currentUser!.uid;

    final chatId = getChatId(
      senderId,
      receiverId,
    );

    await firestore
        .collection("chats")
        .doc(chatId)
        .set({
      "typing": isTyping,
      "typingUser": senderId,
    }, SetOptions(merge: true));
  }
  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final senderId = auth.currentUser!.uid;

    final chatId = getChatId(
      senderId,
      receiverId,
    );

    await firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add({
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "timestamp": FieldValue.serverTimestamp(),
      "type": "text",
      "isRead": false,
    });
  }
  Future<void> sendImage({
    required String receiverId,
    required String imageUrl,
  }) async {
    final senderId = auth.currentUser!.uid;

    final chatId = getChatId(
      senderId,
      receiverId,
    );

    await firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .add({
      "senderId": senderId,
      "receiverId": receiverId,
      "message": imageUrl,
      "timestamp": FieldValue.serverTimestamp(),
      "type": "image",
      "isRead": false,
    });
  }
  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  }) async {
    await firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc(messageId)
        .update({
      "isRead": true,
    });
  }

  Stream<QuerySnapshot> getMessages({
    required String receiverId,
  }) {
    final senderId = auth.currentUser!.uid;

    final chatId = getChatId(
      senderId,
      receiverId,
    );

    return firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy(
      "timestamp",
      descending: false,
    )
        .snapshots();
  }
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }
}
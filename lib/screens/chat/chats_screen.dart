import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatsScreen extends StatelessWidget {
const ChatsScreen({super.key});

@override
Widget build(BuildContext context) {
final uid = FirebaseAuth.instance.currentUser!.uid;

return Scaffold(
appBar: AppBar(
title: const Text("Chats"),
),

body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
.collection("chats")
.snapshots(),

builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
snapshot.data!.docs.isEmpty) {
return const Center(
child: Text(
"No chats yet",
style: TextStyle(fontSize: 18),
),
);
}

final chats = snapshot.data!.docs.where((doc) {
return doc.id.contains(uid);
}).toList();

return ListView.builder(
itemCount: chats.length,

itemBuilder: (context, index) {
  final chat = chats[index];

final ids = chat.id.split("_");

final otherUserId =
ids.first == uid ? ids.last : ids.first;

return FutureBuilder<DocumentSnapshot>(
future: FirebaseFirestore.instance
.collection("users")
.doc(otherUserId)
.get(),

builder: (context, userSnapshot) {

if (!userSnapshot.hasData) {
return const SizedBox();
}

final user = userSnapshot.data!.data()
as Map<String, dynamic>;

return ListTile(

leading: CircleAvatar(

backgroundImage:
user["profileImage"] != null &&
user["profileImage"] != ""
? NetworkImage(
user["profileImage"])
: null,

child: user["profileImage"] == null ||
user["profileImage"] == ""
? const Icon(Icons.person)
: null,
),

title: Text(
user["name"] ?? "",
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: FutureBuilder<QuerySnapshot>(
future: FirebaseFirestore.instance
.collection("chats")
.doc(chat.id)
.collection("messages")
.orderBy(
"timestamp",
descending: true,
)
.limit(1)
.get(),

builder: (context, messageSnapshot) {

if (!messageSnapshot.hasData ||
messageSnapshot
.data!.docs.isEmpty) {
return const Text(
"No messages",
);
}

final message =
messageSnapshot.data!.docs.first;

return Text(
message["message"] ?? "",
maxLines: 1,
overflow:
TextOverflow.ellipsis,
);
},
),

trailing: const Icon(
Icons.arrow_forward_ios,
size: 18,
),

onTap: () {

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => ChatScreen(
receiverId: otherUserId,
  receiverName: user["name"] ?? "",
),
),
);
},
);
},
);
},
);
},
),
);
}
}
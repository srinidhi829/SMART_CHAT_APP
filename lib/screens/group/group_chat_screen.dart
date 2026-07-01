import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/group_service.dart';
import '../chat/message_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() =>
      _GroupChatScreenState();
}

class _GroupChatScreenState
    extends State<GroupChatScreen> {

final GroupService groupService =
GroupService();

final FirebaseAuth auth =
FirebaseAuth.instance;

final TextEditingController messageController =
TextEditingController();

@override
void dispose() {
messageController.dispose();
super.dispose();
}

Future<void> sendMessage() async {

if (messageController.text.trim().isEmpty) {
return;
}

await groupService.sendGroupMessage(
groupId: widget.groupId,
message: messageController.text.trim(),
);

messageController.clear();
}

@override
Widget build(BuildContext context) {

return Scaffold(

appBar: AppBar(
title: Text(widget.groupName),
),

body: Column(

children: [

Expanded(

child: StreamBuilder<QuerySnapshot>(

stream: groupService.getGroupMessages(
widget.groupId,
),

builder: (context, snapshot) {

if (!snapshot.hasData) {
return const Center(
child:
CircularProgressIndicator(),
);
}

final messages =
snapshot.data!.docs;

return ListView.builder(

itemCount: messages.length,

itemBuilder: (context, index) {

final data =
messages[index].data()
as Map<String, dynamic>;
return FutureBuilder<DocumentSnapshot>(

future: FirebaseFirestore.instance
.collection("users")
.doc(data["senderId"])
.get(),

builder: (context, userSnapshot) {

if (!userSnapshot.hasData) {
return const SizedBox();
}

final user =
userSnapshot.data!.data()
as Map<String, dynamic>;

return Column(

crossAxisAlignment:
data["senderId"] == auth.currentUser!.uid
? CrossAxisAlignment.end
: CrossAxisAlignment.start,

children: [

Padding(
padding: const EdgeInsets.symmetric(
horizontal: 15,
),

child: Text(
user["name"] ?? "",
style: const TextStyle(
fontSize: 12,
fontWeight: FontWeight.bold,
color: Colors.blue,
),
),
),

MessageBubble(
isMe:
data["senderId"] ==
auth.currentUser!.uid,

message: data["message"] ?? "",

time:
(data["timestamp"] as Timestamp?)
?.toDate(),

type: data["type"] ?? "text",

isRead: true,
),

],
);

},

);
},
);
},
),
),

  Container(
    padding: const EdgeInsets.all(10),
    color: Colors.white,
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: const InputDecoration(
              hintText: "Type a message...",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        const SizedBox(width: 10),

        CircleAvatar(
          radius: 25,
          child: IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ),
      ],
    ),
  ),
],
),
);
}
}
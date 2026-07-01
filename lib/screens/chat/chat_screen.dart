import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/chat_service.dart';
import 'message_bubble.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;


  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final ChatService chatService = ChatService();

  final StorageService storageService = StorageService();

  final TextEditingController messageController =
  TextEditingController();
  bool showEmoji = false;
  bool isTyping = false;
  @override
void dispose() {
messageController.dispose();
super.dispose();
}

Future<void> sendMessage() async {
if (messageController.text.trim().isEmpty) return;

await chatService.sendMessage(
receiverId: widget.receiverId,
message: messageController.text.trim(),
);

messageController.clear();
isTyping = false;

await chatService.updateTypingStatus(
  receiverId: widget.receiverId,
  isTyping: false,
);
}
Future<void> sendImage() async {
  final image = await storageService.pickImage();

  if (image == null) return;

  final imageUrl = await storageService.uploadChatImage(
    image: image,
  );

  await chatService.sendImage(
    receiverId: widget.receiverId,
    imageUrl: imageUrl,
  );
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
  title: StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection("chats")
        .doc(chatService.getChatId(
      auth.currentUser!.uid,
      widget.receiverId,
    ))
        .snapshots(),
    builder: (context, snapshot) {
      String subtitle = "";

      if (snapshot.hasData &&
          snapshot.data!.exists) {
        final data =
        snapshot.data!.data() as Map<String, dynamic>;

        if (data["typing"] == true &&
            data["typingUser"] != auth.currentUser!.uid) {
          subtitle = "Typing...";
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.receiverName),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
        ],
      );
    },
  ),
),
body: Column(
children: [

Expanded(child: StreamBuilder<QuerySnapshot>(
stream: chatService.getMessages(
receiverId: widget.receiverId,
),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (!snapshot.hasData) {
return const SizedBox();
}

final messages = snapshot.data!.docs;

return ListView.builder(
padding: const EdgeInsets.all(10),
itemCount: messages.length,
itemBuilder: (context, index) {
final data =
messages[index].data() as Map<String, dynamic>;
final chatId = chatService.getChatId(
  auth.currentUser!.uid,
  widget.receiverId,
);

if (data["receiverId"] == auth.currentUser!.uid &&
    data["isRead"] == false) {
  chatService.markMessageAsRead(
    chatId: chatId,
    messageId: messages[index].id,
  );
}
return GestureDetector(
  onLongPress: () {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text("Delete Message"),
            onTap: () async {

              Navigator.pop(context);

              await chatService.deleteMessage(
                chatId: chatId,
                messageId: messages[index].id,
              );

            },
          ),
        );
      },
    );
  },

  child: MessageBubble(
    isMe: data["senderId"] ==
        auth.currentUser!.uid,

    message: data["message"] ?? "",

    time: (data["timestamp"] as Timestamp?)
        ?.toDate(),

    type: data["type"] ?? "text",

    isRead: data["isRead"] ?? false,
  ),
);
},
);
},
),          ),

  Container(
    padding: const EdgeInsets.all(10),
    color: Colors.white,
    child: Row(
      children: [
        IconButton(
          onPressed: sendImage,
          icon: const Icon(
            Icons.photo,
            color: Colors.blue,
          ),
        ),

    Expanded(
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {

            // Shift + Enter → New line
            if (HardwareKeyboard.instance.isShiftPressed) {
              return KeyEventResult.ignored;
            }

            // Enter → Send message
            sendMessage();
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },

        child: TextField(
            controller: messageController,
          maxLines: null,
          textInputAction: TextInputAction.newline,

            onChanged: (value) async {
              if (value.isNotEmpty && !isTyping) {
                isTyping = true;

                await chatService.updateTypingStatus(
                  receiverId: widget.receiverId,
                  isTyping: true,
                );
              }

              if (value.isEmpty && isTyping) {
                isTyping = false;

                await chatService.updateTypingStatus(
                  receiverId: widget.receiverId,
                  isTyping: false,
                );
              }
            },

            decoration: InputDecoration(

              prefixIcon: IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  setState(() {
                    showEmoji = !showEmoji;
                  });
                },
              ),

              hintText: "Type a message...",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
        ),
      ),
        ),

        const SizedBox(width: 10),

        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.blue,
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ),

      ],
    ),
  ),
  if (showEmoji)
    SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          final text = messageController.text;

          messageController.value = TextEditingValue(
            text: text + emoji.emoji,
            selection: TextSelection.collapsed(
              offset: (text + emoji.emoji).length,
            ),
          );
        },
        config: const Config(),
      ),
    ),

],
),
);
}
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final DateTime? time;
  final String type;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        constraints: const BoxConstraints(
          maxWidth: 280,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
            Radius.circular(isMe ? 18 : 0),
            bottomRight:
            Radius.circular(isMe ? 0 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            // --------------------------
            // IMAGE MESSAGE
            // --------------------------
            if (type == "image")
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullImageScreen(
                        imageUrl: message,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    message,
                    width: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                        ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) {
                      return const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )

            // --------------------------
            // TEXT MESSAGE
            // --------------------------
            else
              Text(
                message,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16,
                ),
              ),

            const SizedBox(height: 6),

            // --------------------------
            // TIME + READ RECEIPTS
            // --------------------------
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  time == null
                      ? ""
                      : DateFormat("hh:mm a")
                      .format(time!),
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),

                if (isMe) ...[
                  const SizedBox(width: 5),

                  Icon(
                    isRead
                        ? Icons.done_all
                        : Icons.done,
                    size: 16,
                    color: isRead
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme:
        const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
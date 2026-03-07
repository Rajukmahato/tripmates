import 'package:flutter/material.dart';
import 'package:tripmates/features/chat/domain/entities/message_entity.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isSent;
  final VoidCallback? onDelete;
  final Function(MessageEntity)? onReply;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSent,
    this.onDelete,
    this.onReply,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSent ? AppColors.primary : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(isSent ? 16 : 0),
              bottomRight: Radius.circular(isSent ? 0 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: isSent
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message content
              Text(
                message.content,
                style: TextStyle(
                  color: isSent ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              // Timestamp and read status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSent) ...[
                    if (message.isRead)
                      Icon(Icons.done_all, size: 14, color: Colors.white)
                    else
                      Icon(Icons.done, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                  ],
                  Text(
                    timeFormat,
                    style: TextStyle(
                      color: isSent ? Colors.white70 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              // Edit indicator
              if (message.editedAt != null)
                Text(
                  '(edited)',
                  style: TextStyle(
                    color: isSent ? Colors.white70 : Colors.grey,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubbleWithImages extends StatelessWidget {
  final MessageEntity message;
  final bool isSent;
  final VoidCallback? onDelete;

  const MessageBubbleWithImages({
    super.key,
    required this.message,
    required this.isSent,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Images
            if (message.imageUrls != null && message.imageUrls!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.imageUrls!
                    .map(
                      (url) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.error),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            SizedBox(height: 4),
            // Text content
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSent ? AppColors.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isSent ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    timeFormat,
                    style: TextStyle(
                      color: isSent ? Colors.white70 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:equatable/equatable.dart';

/// Represents a single message in a conversation
class MessageEntity extends Equatable {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isRead;
  final List<String>? imageUrls;
  final String? replyToMessageId;

  const MessageEntity({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.content,
    required this.createdAt,
    this.editedAt,
    this.isRead = false,
    this.imageUrls,
    this.replyToMessageId,
  });

  @override
  List<Object?> get props => [
    messageId,
    conversationId,
    senderId,
    senderName,
    senderProfilePicture,
    content,
    createdAt,
    editedAt,
    isRead,
    imageUrls,
    replyToMessageId,
  ];
}

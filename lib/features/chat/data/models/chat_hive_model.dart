import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';

part 'chat_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.chatTypeId)
// ignore: must_be_immutable
class ChatHiveModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String messageId;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String senderName;

  @HiveField(4)
  final String? senderProfilePicture;

  @HiveField(5)
  final String content;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? editedAt;

  @HiveField(8)
  final bool isRead;

  @HiveField(9)
  final List<String>? imageUrls;

  @HiveField(10)
  final String? replyToMessageId;

  ChatHiveModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.content,
    required this.createdAt,
    this.editedAt,
    required this.isRead,
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

@HiveType(typeId: HiveTableConstant.conversationTypeId)
// ignore: must_be_immutable
class ConversationHiveModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String conversationId;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final List<String> participantIds;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String? lastMessage;

  @HiveField(5)
  final int unreadCount;

  @HiveField(6)
  final String? groupProfilePicture;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final DateTime? lastMessageAt;

  @HiveField(10)
  final String? otherUserProfilePicture;

  @HiveField(11)
  final String? otherUserName;

  ConversationHiveModel({
    required this.conversationId,
    this.name,
    required this.participantIds,
    required this.type,
    this.lastMessage,
    required this.unreadCount,
    this.groupProfilePicture,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.otherUserProfilePicture,
    this.otherUserName,
  });

  @override
  List<Object?> get props => [
    conversationId,
    name,
    participantIds,
    type,
    lastMessage,
    unreadCount,
    groupProfilePicture,
    createdAt,
    updatedAt,
    lastMessageAt,
    otherUserProfilePicture,
    otherUserName,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:tripmates/core/api/api_endpoints.dart';

int? _parseIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

/// Convert relative image paths to complete URLs
String? _buildImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;

  // If already a complete URL, return as is
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }

  // If relative path, prepend base origin
  if (path.startsWith('/')) {
    return '${ApiEndpoints.baseOrigin}$path';
  }

  // Otherwise prepend with /uploads/
  return '${ApiEndpoints.baseOrigin}/uploads/$path';
}

class ChatApiModel extends Equatable {
  final String? messageId;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final String content;
  final String createdAt;
  final String? editedAt;
  final bool? isRead;
  final List<String>? imageUrls;
  final String? replyToMessageId;

  const ChatApiModel({
    this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.content,
    required this.createdAt,
    this.editedAt,
    this.isRead,
    this.imageUrls,
    this.replyToMessageId,
  });

  factory ChatApiModel.fromJson(Map<String, dynamic> json) {
    try {
      // Extract sender information from sender object
      final senderObj = json['sender'] as Map<String, dynamic>?;
      final senderId =
          senderObj?['_id'] as String? ?? json['senderId'] as String?;
      final senderName =
          senderObj?['fullName'] as String? ?? json['senderName'] as String?;
      final senderProfilePicture =
          senderObj?['profileImagePath'] as String? ??
          json['senderProfilePicture'] as String?;

      final conversationId =
          json['conversationId'] as String? ??
          json['conversation'] as String? ??
          '';

      final content = json['content'] as String? ?? '';
      final createdAt =
          json['createdAt'] as String? ?? DateTime.now().toIso8601String();

      return ChatApiModel(
        messageId: json['messageId'] as String? ?? json['_id'] as String?,
        conversationId: conversationId,
        senderId: senderId ?? '',
        senderName: senderName ?? 'Unknown',
        senderProfilePicture: _buildImageUrl(senderProfilePicture),
        content: content,
        createdAt: createdAt,
        editedAt: json['editedAt'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        imageUrls: json['imageUrls'] != null
            ? List<String>.from(json['imageUrls'] as List)
            : null,
        replyToMessageId: json['replyToMessageId'] as String?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderProfilePicture': senderProfilePicture,
      'content': content,
      'createdAt': createdAt,
      'editedAt': editedAt,
      'isRead': isRead,
      'imageUrls': imageUrls,
      'replyToMessageId': replyToMessageId,
    };
  }

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

class ConversationApiModel extends Equatable {
  final String conversationId;
  final String? name;
  final List<String> participantIds;
  final String type;
  final String? lastMessage;
  final int? unreadCount;
  final String? groupProfilePicture;
  final String createdAt;
  final String updatedAt;
  final String? lastMessageAt;
  final String? otherUserProfilePicture; // For 1-on-1 chats
  final String? otherUserName; // For 1-on-1 chats
  final String? tripId; // For group chats

  const ConversationApiModel({
    required this.conversationId,
    this.name,
    required this.participantIds,
    required this.type,
    this.lastMessage,
    this.unreadCount,
    this.groupProfilePicture,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.otherUserProfilePicture,
    this.otherUserName,
    this.tripId,
  });

  factory ConversationApiModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value['_id'] as String?;
      return value as String?;
    }

    List<String> parseParticipants(dynamic value) {
      if (value is List) {
        return value
            .map((item) => extractId(item) ?? item.toString())
            .where((id) => id.isNotEmpty)
            .toList();
      }
      return const [];
    }

    String? extractLastMessageContent(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return value['content'] as String?;
      }
      return null;
    }

    final conversationId =
        json['conversationId'] as String? ?? json['_id'] as String? ?? '';

    // Handle participants from otherUser (new API structure)
    List<String> participantIds = [];
    String? conversationName;
    String? otherUserProfilePicture;
    String? otherUserName;
    String? tripId;

    if (json['otherUser'] is Map<String, dynamic>) {
      // New API structure: has otherUser object with _id and fullName
      final otherUser = json['otherUser'] as Map<String, dynamic>;
      final otherUserId = otherUser['_id'] as String?;
      otherUserName = otherUser['fullName'] as String?;
      otherUserProfilePicture = _buildImageUrl(
        otherUser['profileImagePath'] as String?,
      );

      if (otherUserId != null) {
        participantIds.add(otherUserId);
      }
      conversationName = otherUserName;
    } else if (json['participant'] is Map<String, dynamic>) {
      // API structure with participant field (for conversations endpoint)
      final participant = json['participant'] as Map<String, dynamic>;
      final otherUserId = participant['_id'] as String?;
      otherUserName = participant['fullName'] as String?;
      otherUserProfilePicture = _buildImageUrl(
        participant['profileImagePath'] as String? ??
            participant['profileImage'] as String?,
      );

      if (otherUserId != null) {
        participantIds.add(otherUserId);
      }
      conversationName = otherUserName;
    } else {
      // Fallback to old API structure
      participantIds = parseParticipants(
        json['participantIds'] ?? json['participants'],
      );
      conversationName = json['name'] as String?;
    }

    // Extract tripId for group chats
    tripId = json['tripId'] as String?;

    return ConversationApiModel(
      conversationId: conversationId,
      name: conversationName,
      participantIds: participantIds,
      type: json['type'] as String? ?? 'oneOnOne',
      lastMessage: extractLastMessageContent(json['lastMessage']),
      unreadCount: _parseIntValue(json['unreadCount']),
      groupProfilePicture: _buildImageUrl(
        json['groupProfilePicture'] as String?,
      ),
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      lastMessageAt: json['lastMessageAt'] as String?,
      otherUserProfilePicture: otherUserProfilePicture,
      otherUserName: otherUserName,
      tripId: tripId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'name': name,
      'participantIds': participantIds,
      'type': type,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'groupProfilePicture': groupProfilePicture,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastMessageAt': lastMessageAt,
      'otherUserProfilePicture': otherUserProfilePicture,
      'otherUserName': otherUserName,
      'tripId': tripId,
    };
  }

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
    tripId,
  ];
}

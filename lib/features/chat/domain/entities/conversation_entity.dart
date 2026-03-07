import 'package:equatable/equatable.dart';

enum ConversationType { oneOnOne, group }

/// Represents a conversation (1-on-1 or group chat)
class ConversationEntity extends Equatable {
  final String conversationId;
  final String? name; // For group chats
  final ConversationType type;
  final List<String> participantIds;
  final String? groupProfilePicture;
  final String? lastMessage; // Last message text preview
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? otherUserProfilePicture; // For 1-on-1 chats
  final String? tripId; // For group chats
  final String? otherUserName; // For 1-on-1 chats, actual user name

  const ConversationEntity({
    required this.conversationId,
    this.name,
    required this.type,
    required this.participantIds,
    this.groupProfilePicture,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.otherUserProfilePicture,
    this.tripId,
    this.otherUserName,
  });

  /// Get the display name for the conversation
  String getDisplayName(String currentUserId) {
    if (type == ConversationType.group) {
      return name ?? 'Group Chat';
    }

    // For 1-on-1, return user name if available, otherwise user ID
    if (otherUserName != null && otherUserName!.isNotEmpty) {
      return otherUserName!;
    }

    // Fallback to the other participant ID
    final otherUserId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return otherUserId.isNotEmpty ? otherUserId : 'Unknown';
  }

  // Get the other participant ID for 1-on-1 chats
  String? getOtherParticipantId(String currentUserId) {
    if (type != ConversationType.oneOnOne) return null;
    try {
      return participantIds.firstWhere((id) => id != currentUserId);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    conversationId,
    name,
    type,
    participantIds,
    groupProfilePicture,
    lastMessage,
    lastMessageAt,
    unreadCount,
    createdAt,
    updatedAt,
    otherUserProfilePicture,
    tripId,
    otherUserName,
  ];
}

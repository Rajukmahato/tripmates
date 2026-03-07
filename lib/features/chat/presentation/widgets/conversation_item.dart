import 'package:flutter/material.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ConversationItem extends StatelessWidget {
  final ConversationEntity conversation;
  final String currentUserId;
  final bool isSelected;
  final bool isOnline;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.isSelected,
    this.isOnline = false,
    required this.onTap,
    this.onLongPress,
  });

  String _getDisplayName() {
    return conversation.getDisplayName(currentUserId);
  }

  ImageProvider<Object>? _getAvatarImage() {
    // For group chats, use group profile picture
    if (conversation.type == ConversationType.group &&
        conversation.groupProfilePicture != null) {
      return NetworkImage(conversation.groupProfilePicture!);
    }

    // For 1-on-1 chats, use other user's profile picture
    if (conversation.type == ConversationType.oneOnOne &&
        conversation.otherUserProfilePicture != null) {
      return NetworkImage(conversation.otherUserProfilePicture!);
    }

    return null;
  }

  String _getTimeDisplay() {
    if (conversation.lastMessageAt == null) return '';
    final now = DateTime.now();
    final messageTime = conversation.lastMessageAt!;

    if (now.year == messageTime.year &&
        now.month == messageTime.month &&
        now.day == messageTime.day) {
      return DateFormat('HH:mm').format(messageTime);
    } else if (now.difference(messageTime).inDays <= 7) {
      return DateFormat('EEE').format(messageTime);
    } else {
      return DateFormat('MMM dd').format(messageTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        border: isSelected
            ? Border(left: BorderSide(color: AppColors.primary, width: 4))
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: _getAvatarImage(),
              child: _getAvatarImage() == null
                  ? Text(
                      _getDisplayName().isEmpty
                          ? '?'
                          : _getDisplayName().substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            // Online status indicator (green dot)
            if (isOnline && conversation.type == ConversationType.oneOnOne)
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          _getDisplayName(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: conversation.unreadCount > 0
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          conversation.lastMessage ?? 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: conversation.unreadCount > 0
                ? FontWeight.w500
                : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getTimeDisplay(),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            if (conversation.unreadCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ConversationItemLoading extends StatelessWidget {
  const ConversationItemLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(radius: 28, backgroundColor: Colors.grey[300]),
      title: Container(height: 16, color: Colors.grey[300]),
      subtitle: Container(
        height: 12,
        color: Colors.grey[200],
        margin: EdgeInsets.only(top: 8),
      ),
    );
  }
}

class ConversationEmptyState extends StatelessWidget {
  final VoidCallback? onCreateChat;

  const ConversationEmptyState({super.key, this.onCreateChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation to get chatting!',
            style: TextStyle(color: Colors.grey[500]),
          ),
          if (onCreateChat != null) ...[
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateChat,
              icon: Icon(Icons.add),
              label: Text('New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

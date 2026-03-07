import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/presentation/view_model/chat_viewmodel.dart';
import 'package:tripmates/features/chat/presentation/state/chat_state.dart';
import 'package:tripmates/features/chat/presentation/widgets/message_bubble.dart';
import 'package:tripmates/features/chat/presentation/widgets/message_input_field.dart';
import 'package:tripmates/app/theme/app_colors.dart';

class ConversationDetailPage extends ConsumerStatefulWidget {
  final ConversationEntity conversation;

  const ConversationDetailPage({super.key, required this.conversation});

  @override
  ConsumerState<ConversationDetailPage> createState() =>
      _ConversationDetailPageState();
}

class _ConversationDetailPageState
    extends ConsumerState<ConversationDetailPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatViewModelProvider.notifier)
          .loadMessages(widget.conversation.conversationId);
      _scrollToBottom();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      // Load more messages when user scrolls near top (pagination not yet implemented)
      // When implemented, add: viewmodel.loadMoreMessages(widget.conversation.conversationId);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final chatNotifier = ref.read(chatViewModelProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(chatNotifier, chatState),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessageList(chatState, chatNotifier)),
            if (chatState.isTyping && chatState.typingUsers.isNotEmpty)
              _buildTypingIndicator(chatState.typingUsers.length),
            MessageInputField(
              conversationId: widget.conversation.conversationId,
              onSendMessage: (content, {imageUrls, replyToMessageId}) {
                chatNotifier.sendMessage(
                  widget.conversation.conversationId,
                  content,
                  imageUrls: imageUrls,
                  replyToMessageId: replyToMessageId,
                );
                _scrollToBottom();
              },
              onTyping: (isTyping) {
                final userId = chatNotifier.getCurrentUserId();
                if (userId != null) {
                  chatNotifier.sendTypingIndicator(
                    widget.conversation.conversationId,
                    userId,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(int typingCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (index) => AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            typingCount == 1
                ? 'Someone is typing...'
                : '$typingCount people are typing...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ChatViewModel chatNotifier,
    ChatState chatState,
  ) {
    final displayName = widget.conversation.getDisplayName(
      chatNotifier.getCurrentUserId() ?? '',
    );
    final participantCount = widget.conversation.participantIds.length;

    // Get presence status for 1-on-1 chats
    String presenceText = '';
    if (widget.conversation.type == ConversationType.oneOnOne &&
        widget.conversation.participantIds.length == 2) {
      final otherUserId = widget.conversation.participantIds.firstWhere(
        (id) => id != chatNotifier.getCurrentUserId(),
        orElse: () => '',
      );

      if (otherUserId.isNotEmpty) {
        if (chatState.onlineUsers.contains(otherUserId)) {
          presenceText = 'Active now';
        } else if (chatState.lastSeenMap.containsKey(otherUserId)) {
          final lastSeen = chatState.lastSeenMap[otherUserId]!;
          presenceText = _getLastSeenText(lastSeen);
        }
      }
    } else if (widget.conversation.type == ConversationType.group) {
      presenceText = '$participantCount participants';
    }

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (presenceText.isNotEmpty)
            Text(
              presenceText,
              style: TextStyle(
                fontSize: 12,
                color: presenceText == 'Active now'
                    ? Colors.green
                    : Colors.grey[600],
                fontWeight: presenceText == 'Active now'
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.call, color: Colors.black),
          onPressed: () {
            _initiateVideoCall(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.info_outline, color: Colors.black),
          onPressed: () {
            _showConversationInfo(context);
          },
        ),
      ],
    );
  }

  Widget _buildMessageList(ChatState chatState, ChatViewModel chatNotifier) {
    if (chatState.isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (chatState.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Failed to load messages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (chatState.errorMessage != null) ...[
                SizedBox(height: 8),
                Text(
                  chatState.errorMessage!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 8),
              Text(
                'ConversationId: ${widget.conversation.conversationId}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  chatNotifier.loadMessages(widget.conversation.conversationId);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (chatState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        final isSent = message.senderId == chatNotifier.getCurrentUserId();

        return Column(
          crossAxisAlignment: isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (message.imageUrls != null && message.imageUrls!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  right: isSent ? 16 : 0,
                  left: isSent ? 0 : 16,
                  bottom: 8,
                ),
                child: MessageBubbleWithImages(
                  message: message,
                  isSent: isSent,
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(
                  right: isSent ? 16 : 0,
                  left: isSent ? 0 : 16,
                  bottom: 8,
                ),
                child: MessageBubble(message: message, isSent: isSent),
              ),
          ],
        );
      },
    );
  }

  String _getLastSeenText(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays}d ago';
    } else {
      return 'Last seen ${DateFormat('MMM d').format(lastSeen)}';
    }
  }

  void _showConversationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conversation Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversation ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              widget.conversation.conversationId,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              'Participants',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            ...widget.conversation.participantIds.map(
              (id) => Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('• $id', style: TextStyle(fontSize: 12)),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Created',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              DateFormat(
                'MMM d, yyyy • HH:mm',
              ).format(widget.conversation.createdAt),
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _initiateVideoCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Video Call'),
        content: Text(
          'Video calling feature requires integration with a video SDK like Agora, Twilio, or WebRTC. Would you like to start a call?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Video SDK not configured yet'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Start Call'),
          ),
        ],
      ),
    );
  }
}

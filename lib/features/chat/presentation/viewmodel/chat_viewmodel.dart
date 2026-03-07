import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/core/services/socket/socket_service.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/domain/entities/message_entity.dart';
import 'package:tripmates/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/create_conversation_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/send_typing_indicator_usecase.dart';
import 'package:tripmates/features/chat/presentation/state/chat_state.dart';

final chatViewmodelProvider = NotifierProvider<ChatViewmodel, ChatState>(
  ChatViewmodel.new,
);

class ChatViewmodel extends Notifier<ChatState> {
  late final UserSessionService _sessionService;
  late final SocketService _socketService;
  late final GetConversationsUsecase _getConversationsUsecase;
  late final GetMessagesUsecase _getMessagesUsecase;
  late final SendMessageUsecase _sendMessageUsecase;
  late final CreateConversationUsecase _createConversationUsecase;
  late final SendTypingIndicatorUsecase _sendTypingIndicatorUsecase;

  @override
  ChatState build() {
    _sessionService = ref.read(userSessionServiceProvider);
    _socketService = ref.read(socketServiceProvider);
    _getConversationsUsecase = ref.read(getConversationsUsecaseProvider);
    _getMessagesUsecase = ref.read(getMessagesUsecaseProvider);
    _sendMessageUsecase = ref.read(sendMessageUsecaseProvider);
    _createConversationUsecase = ref.read(createConversationUsecaseProvider);
    _sendTypingIndicatorUsecase = ref.read(sendTypingIndicatorUsecaseProvider);

    _initializeSocketListeners();

    return const ChatState();
  }

  /// Initialize socket event listeners
  void _initializeSocketListeners() {
    // Listen for new messages
    _socketService.onNewMessage((data) {
      _handleNewMessage(data);
    });

    // Listen for typing indicators
    _socketService.onTypingIndicator((data) {
      _handleTypingIndicator(data);
    });

    // Listen for message read receipts
    _socketService.onMessageRead((data) {
      _handleMessageRead(data);
    });

    // Listen for user online/offline status
    _socketService.onUserOnline((data) {
      _handleUserOnline(data);
    });

    _socketService.onUserOffline((data) {
      _handleUserOffline(data);
    });
  }

  /// Handle incoming new message from socket
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final conversationId = data['conversationId'] as String?;
      final messageId = data['messageId'] as String?;
      final senderId = data['senderId'] as String?;
      final senderName = data['senderName'] as String?;
      final content = data['content'] as String?;
      final timestamp = data['timestamp'] as String?;

      if (conversationId == null ||
          messageId == null ||
          senderId == null ||
          content == null ||
          timestamp == null) {
        return;
      }

      final message = MessageEntity(
        messageId: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName ?? 'Unknown',
        content: content,
        imageUrls: (data['imageUrls'] as List?)?.cast<String>(),
        replyToMessageId: data['replyToMessageId'] as String?,
        isRead: false,
        createdAt: DateTime.parse(timestamp),
      );

      // Add message to current conversation if it matches
      if (state.selectedConversation?.conversationId == conversationId) {
        final updatedMessages = [message, ...state.messages];
        state = state.copyWith(messages: updatedMessages);
      }

      // Update conversation last message
      _updateConversationLastMessage(
        conversationId,
        content,
        DateTime.parse(timestamp),
      );
    } catch (e) {
      // Silently handle errors in real-time updates
    }
  }

  /// Handle typing indicator from socket
  void _handleTypingIndicator(Map<String, dynamic> data) {
    try {
      final conversationId = data['conversationId'] as String?;
      final userId = data['userId'] as String?;
      final isTyping = data['isTyping'] as bool? ?? false;

      if (conversationId == null || userId == null) return;
      if (userId == currentUserId) return; // Ignore own typing

      if (state.selectedConversation?.conversationId == conversationId) {
        if (isTyping) {
          final updatedTypingUsers = [...state.typingUsers, userId];
          state = state.copyWith(
            typingUsers: updatedTypingUsers,
            isTyping: true,
          );
        } else {
          final updatedTypingUsers = state.typingUsers
              .where((id) => id != userId)
              .toList();
          state = state.copyWith(
            typingUsers: updatedTypingUsers,
            isTyping: updatedTypingUsers.isNotEmpty,
          );
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Handle message read receipt
  void _handleMessageRead(Map<String, dynamic> data) {
    try {
      final messageId = data['messageId'] as String?;
      if (messageId == null) return;

      final updatedMessages = state.messages.map((msg) {
        if (msg.messageId == messageId) {
          return MessageEntity(
            messageId: msg.messageId,
            conversationId: msg.conversationId,
            senderId: msg.senderId,
            senderName: msg.senderName,
            content: msg.content,
            imageUrls: msg.imageUrls,
            replyToMessageId: msg.replyToMessageId,
            isRead: true,
            createdAt: msg.createdAt,
            editedAt: msg.editedAt,
          );
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Handle user online status
  void _handleUserOnline(Map<String, dynamic> data) {
    try {
      final userId = data['userId'] as String;

      // Add user to online users set
      final updatedOnlineUsers = Set<String>.from(state.onlineUsers)
        ..add(userId);

      // Remove from lastSeen map since user is now online
      final updatedLastSeenMap = Map<String, DateTime>.from(state.lastSeenMap)
        ..remove(userId);

      state = state.copyWith(
        onlineUsers: updatedOnlineUsers,
        lastSeenMap: updatedLastSeenMap,
      );
    } catch (e) {
      // Silent failure for non-critical presence updates
    }
  }

  /// Handle user offline status
  void _handleUserOffline(Map<String, dynamic> data) {
    try {
      final userId = data['userId'] as String;
      final lastSeenStr = data['lastSeen'] as String?;

      // Remove user from online users set
      final updatedOnlineUsers = Set<String>.from(state.onlineUsers)
        ..remove(userId);

      // Add to lastSeen map
      final updatedLastSeenMap = Map<String, DateTime>.from(state.lastSeenMap);
      if (lastSeenStr != null) {
        try {
          updatedLastSeenMap[userId] = DateTime.parse(lastSeenStr);
        } catch (e) {
          // If parsing fails, use current time
          updatedLastSeenMap[userId] = DateTime.now();
        }
      }

      state = state.copyWith(
        onlineUsers: updatedOnlineUsers,
        lastSeenMap: updatedLastSeenMap,
      );
    } catch (e) {
      // Silent failure for non-critical presence updates
    }
  }

  /// Update conversation last message
  void _updateConversationLastMessage(
    String conversationId,
    String lastMessage,
    DateTime timestamp,
  ) {
    final updatedConversations = state.conversations.map((conv) {
      if (conv.conversationId == conversationId) {
        return ConversationEntity(
          conversationId: conv.conversationId,
          name: conv.name,
          type: conv.type,
          participantIds: conv.participantIds,
          groupProfilePicture: conv.groupProfilePicture,
          lastMessage: lastMessage,
          lastMessageAt: timestamp,
          unreadCount: conv.unreadCount + 1,
          createdAt: conv.createdAt,
          updatedAt: timestamp,
        );
      }
      return conv;
    }).toList();

    state = state.copyWith(conversations: updatedConversations);
  }

  String? get currentUserId => _sessionService.getUserId();
  String? get currentUserName => _sessionService.getUserFullName();

  // Load conversations
  Future<void> loadConversations() async {
    state = state.copyWith(status: ChatStatus.loading);

    if (currentUserId == null) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'User not authenticated',
      );
      return;
    }

    final result = await _getConversationsUsecase(
      GetConversationsParams(userId: currentUserId!),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: failure.message,
      ),
      (conversations) => state = state.copyWith(
        status: ChatStatus.loaded,
        conversations: conversations,
      ),
    );
  }

  // Load messages for a conversation
  Future<void> loadMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    state = state.copyWith(status: ChatStatus.loading);

    final result = await _getMessagesUsecase(
      GetMessagesParams(
        conversationId: conversationId,
        limit: limit,
        before: before,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: failure.message,
      ),
      (messages) {
        // Sort messages by createdAt descending (newest first)
        final sortedMessages = List<MessageEntity>.from(messages)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        state = state.copyWith(
          status: ChatStatus.loaded,
          messages: sortedMessages,
        );
      },
    );
  }

  // Send a message
  Future<void> sendMessage(
    String conversationId,
    String content, {
    List<String>? imageUrls,
    String? replyToMessageId,
  }) async {
    state = state.copyWith(status: ChatStatus.sending);

    if (currentUserId == null || currentUserName == null) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'User not authenticated',
      );
      return;
    }

    final result = await _sendMessageUsecase(
      SendMessageParams(
        conversationId: conversationId,
        senderId: currentUserId!,
        senderName: currentUserName!,
        content: content,
        imageUrls: imageUrls,
        replyToMessageId: replyToMessageId,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: failure.message,
      ),
      (message) {
        final updatedMessages = [message, ...state.messages];
        state = state.copyWith(
          status: ChatStatus.messageSent,
          messages: updatedMessages,
        );

        // Emit message via socket for real-time delivery
        _socketService.sendMessage(
          conversationId: conversationId,
          content: content,
          imageUrls: imageUrls,
          replyToId: replyToMessageId,
        );
      },
    );
  }

  // Create a conversation
  Future<void> createConversation({
    required ConversationType type,
    required List<String> participantIds,
    String? groupName,
    String? groupProfilePicture,
  }) async {
    state = state.copyWith(status: ChatStatus.loading);

    if (currentUserId == null) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'User not authenticated',
      );
      return;
    }

    final result = await _createConversationUsecase(
      CreateConversationParams(
        type: type,
        initiatorId: currentUserId!,
        participantIds: participantIds,
        groupName: groupName,
        groupProfilePicture: groupProfilePicture,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: failure.message,
      ),
      (conversation) {
        final updatedConversations = [conversation, ...state.conversations];
        state = state.copyWith(
          status: ChatStatus.loaded,
          conversations: updatedConversations,
          selectedConversation: conversation,
        );
      },
    );
  }

  // Send typing indicator
  Future<void> sendTypingIndicator(String conversationId) async {
    if (currentUserId == null) return;

    // Emit via socket for real-time
    _socketService.sendTypingIndicator(
      conversationId: conversationId,
      isTyping: true,
    );

    await _sendTypingIndicatorUsecase(
      SendTypingIndicatorParams(
        conversationId: conversationId,
        userId: currentUserId!,
      ),
    );
  }

  // Select a conversation
  void selectConversation(ConversationEntity conversation) {
    state = state.copyWith(selectedConversation: conversation);

    // Join socket room for this conversation
    _socketService.joinConversation(conversation.conversationId);
  }

  // Update typing status
  void updateTypingStatus(String conversationId, bool isTyping) {
    state = state.copyWith(isTyping: isTyping);

    // Emit typing status via socket
    _socketService.sendTypingIndicator(
      conversationId: conversationId,
      isTyping: isTyping,
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(errorMessage: '', status: ChatStatus.loaded);
  }

  // Reset state
  void resetState() {
    // Leave all socket rooms and clear listeners
    if (state.selectedConversation != null) {
      _socketService.leaveConversation(
        state.selectedConversation!.conversationId,
      );
    }
    state = const ChatState();
  }
}

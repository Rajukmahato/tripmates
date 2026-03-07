import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/features/chat/domain/usecases/create_conversation_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/send_typing_indicator_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/get_group_chat_by_group_id_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/get_group_chat_by_trip_id_usecase.dart';
import 'package:tripmates/features/chat/domain/usecases/group_member_usecases.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/presentation/state/chat_state.dart';

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(
  ChatViewModel.new,
);

class ChatViewModel extends Notifier<ChatState> {
  late final UserSessionService _userSessionService;
  late final CreateConversationUsecase _createConversationUseCase;
  late final GetConversationsUsecase _getConversationsUseCase;
  late final SendMessageUsecase _sendMessageUseCase;
  late final GetMessagesUsecase _getMessagesUseCase;
  late final MarkAsReadUsecase _markAsReadUseCase;
  late final SendTypingIndicatorUsecase _sendTypingIndicatorUseCase;
  late final GetGroupChatByGroupIdUsecase _getGroupChatByGroupIdUsecase;
  late final GetGroupChatByTripIdUsecase _getGroupChatByTripIdUsecase;
  late final AddParticipantUsecase _addParticipantUsecase;
  late final RemoveParticipantUsecase _removeParticipantUsecase;

  @override
  ChatState build() {
    _userSessionService = ref.read(userSessionServiceProvider);
    _createConversationUseCase = ref.read(createConversationUsecaseProvider);
    _getConversationsUseCase = ref.read(getConversationsUsecaseProvider);
    _sendMessageUseCase = ref.read(sendMessageUsecaseProvider);
    _getMessagesUseCase = ref.read(getMessagesUsecaseProvider);
    _markAsReadUseCase = ref.read(markAsReadUsecaseProvider);
    _sendTypingIndicatorUseCase = ref.read(sendTypingIndicatorUsecaseProvider);
    _getGroupChatByGroupIdUsecase = ref.read(
      getGroupChatByGroupIdUsecaseProvider,
    );
    _getGroupChatByTripIdUsecase = ref.read(
      getGroupChatByTripIdUsecaseProvider,
    );
    _addParticipantUsecase = ref.read(addParticipantUsecaseProvider);
    _removeParticipantUsecase = ref.read(removeParticipantUsecaseProvider);
    return const ChatState();
  }

  /// Create a one-on-one conversation
  Future<bool> createOneOnOneConversation(
    String userId1,
    String userId2,
  ) async {
    state = state.copyWith(status: ChatStatus.loading);
    log(
      'createOneOnOneConversation: Creating conversation between $userId1 and $userId2',
    );

    final result = await _createConversationUseCase(
      CreateConversationParams(
        type: ConversationType.oneOnOne,
        initiatorId: userId1,
        participantIds: [userId2],
      ),
    );

    final success = result.fold(
      (failure) {
        log('createOneOnOneConversation: Error - ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (conversation) {
        log(
          'createOneOnOneConversation: Success! Created conversation ${conversation.conversationId}',
        );
        state = state.copyWith(
          status: ChatStatus.loaded,
          conversations: [...state.conversations, conversation],
          selectedConversation: conversation,
          errorMessage: null,
        );
        return true;
      },
    );

    return success;
  }

  /// Create a group conversation
  Future<bool> createGroupConversation({
    required String createdBy,
    required List<String> participantIds,
    required String groupName,
    String? groupProfilePicture,
    String? tripId,
  }) async {
    state = state.copyWith(status: ChatStatus.loading);
    log(
      'createGroupConversation: Creating group "$groupName" for tripId: $tripId with ${participantIds.length} participants',
    );

    final result = await _createConversationUseCase(
      CreateConversationParams(
        type: ConversationType.group,
        initiatorId: createdBy,
        participantIds: participantIds,
        groupName: groupName,
        groupProfilePicture: groupProfilePicture,
        tripId: tripId,
      ),
    );

    final success = result.fold(
      (failure) {
        log('createGroupConversation: Error - ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (conversation) {
        log(
          'createGroupConversation: Success! Created group conversation ${conversation.conversationId}',
        );
        state = state.copyWith(
          status: ChatStatus.loaded,
          conversations: [...state.conversations, conversation],
          selectedConversation: conversation,
          errorMessage: null,
        );
        return true;
      },
    );

    return success;
  }

  /// Load all conversations for a user
  Future<void> loadConversations(String userId) async {
    state = state.copyWith(status: ChatStatus.loading);
    log(
      '📱 [ChatViewModel] loadConversations: Loading conversations for user=$userId',
    );

    final result = await _getConversationsUseCase(
      GetConversationsParams(userId: userId),
    );

    result.fold(
      (failure) {
        log('❌ [ChatViewModel] loadConversations: Error - ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
      },
      (conversations) {
        log(
          '✅ [ChatViewModel] loadConversations: Success! Got ${conversations.length} conversations',
        );
        for (final conv in conversations) {
          log(
            '   - ${conv.conversationId}: ${conv.type} (${conv.name ?? "Direct Message"})',
          );
        }
        state = state.copyWith(
          status: ChatStatus.loaded,
          conversations: conversations,
          errorMessage: null,
        );
      },
    );
  }

  /// Load group chat by groupChatId
  Future<ConversationEntity?> loadGroupChatByGroupId(String groupChatId) async {
    state = state.copyWith(status: ChatStatus.loading);
    log('📱 [ChatViewModel] loadGroupChatByGroupId: $groupChatId');

    final result = await _getGroupChatByGroupIdUsecase(
      GetGroupChatByGroupIdParams(groupChatId: groupChatId),
    );

    return result.fold(
      (failure) {
        log('❌ [ChatViewModel] loadGroupChatByGroupId: ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (conversation) {
        log(
          '✅ [ChatViewModel] loadGroupChatByGroupId: ${conversation.conversationId}',
        );
        state = state.copyWith(
          status: ChatStatus.loaded,
          selectedConversation: conversation,
          errorMessage: null,
        );
        return conversation;
      },
    );
  }

  /// Load group chat by tripId
  Future<ConversationEntity?> loadGroupChatByTripId(String tripId) async {
    state = state.copyWith(status: ChatStatus.loading);
    log('📱 [ChatViewModel] loadGroupChatByTripId: $tripId');

    final result = await _getGroupChatByTripIdUsecase(
      GetGroupChatByTripIdParams(tripId: tripId),
    );

    return result.fold(
      (failure) {
        log('❌ [ChatViewModel] loadGroupChatByTripId: ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (conversation) {
        log(
          '✅ [ChatViewModel] loadGroupChatByTripId: ${conversation.conversationId}',
        );
        state = state.copyWith(
          status: ChatStatus.loaded,
          selectedConversation: conversation,
          errorMessage: null,
        );
        return conversation;
      },
    );
  }

  /// Load messages for a conversation
  Future<void> loadMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    state = state.copyWith(status: ChatStatus.loading);
    log('loadMessages: Loading messages for conversation=$conversationId');

    final result = await _getMessagesUseCase(
      GetMessagesParams(
        conversationId: conversationId,
        limit: limit,
        before: before,
      ),
    );

    result.fold(
      (failure) {
        log('loadMessages: Error - ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
      },
      (messages) {
        log('loadMessages: Success! Got ${messages.length} messages');
        state = state.copyWith(
          status: ChatStatus.loaded,
          messages: messages,
          errorMessage: null,
        );
      },
    );
  }

  /// Send a message
  Future<bool> sendMessage(
    String conversationId,
    String content, {
    String? senderId,
    String? senderName,
    List<String>? imageUrls,
    String? replyToMessageId,
  }) async {
    state = state.copyWith(status: ChatStatus.sending);
    log(
      '🔁 [ChatViewModel] sendMessage: Sending to conversation=$conversationId',
    );

    // Extract sender info from session if not provided
    final actualSenderId = senderId ?? _userSessionService.getCurrentUserId();
    final actualSenderName =
        senderName ?? _userSessionService.getCurrentUserFullName();

    if (actualSenderId == null || actualSenderName == null) {
      log('❌ [ChatViewModel] sendMessage: User not authenticated');
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'User not authenticated',
      );
      return false;
    }

    final result = await _sendMessageUseCase(
      SendMessageParams(
        conversationId: conversationId,
        senderId: actualSenderId,
        senderName: actualSenderName,
        content: content,
        imageUrls: imageUrls,
        replyToMessageId: replyToMessageId,
      ),
    );

    final success = result.fold(
      (failure) {
        log('sendMessage: Error - ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (message) {
        log('sendMessage: Success! Sent message ${message.messageId}');
        state = state.copyWith(
          status: ChatStatus.messageSent,
          messages: [message, ...state.messages],
          errorMessage: null,
        );
        return true;
      },
    );

    return success;
  }

  /// Mark a message as read
  Future<void> markAsRead(String messageId) async {
    log('markAsRead: Marking message=$messageId as read');

    final result = await _markAsReadUseCase(
      MarkAsReadParams(messageId: messageId),
    );

    result.fold(
      (failure) {
        log('markAsRead: Error - ${failure.message}');
      },
      (_) {
        log('markAsRead: Success!');
        // Update message status in local state
        final updatedMessages = state.messages.map((msg) {
          if (msg.messageId == messageId) {
            // Assuming the message entity has an isRead property
            // This might need adjustment based on actual entity structure
            return msg;
          }
          return msg;
        }).toList();
        state = state.copyWith(messages: updatedMessages);
      },
    );
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, String userId) async {
    log(
      'sendTypingIndicator: User=$userId typing in conversation=$conversationId',
    );

    final result = await _sendTypingIndicatorUseCase(
      SendTypingIndicatorParams(conversationId: conversationId, userId: userId),
    );

    result.fold(
      (failure) {
        log('sendTypingIndicator: Error - ${failure.message}');
      },
      (_) {
        log('sendTypingIndicator: Success!');
        state = state.copyWith(status: ChatStatus.typingIndicator);
      },
    );
  }

  /// Select a conversation
  void selectConversation(dynamic conversation) {
    ConversationEntity? conv;

    if (conversation is ConversationEntity) {
      conv = conversation;
    } else if (conversation is String) {
      try {
        conv = state.conversations.firstWhere(
          (c) => c.conversationId == conversation,
        );
      } catch (e) {
        return;
      }
    }

    if (conv != null) {
      state = state.copyWith(selectedConversation: conv, messages: const []);
    }
  }

  /// Add a participant to a group conversation
  Future<bool> addParticipant(String conversationId, String userId) async {
    log(
      '🔁 [ChatViewModel] addParticipant: Adding $userId to conversation=$conversationId',
    );

    final result = await _addParticipantUsecase(
      AddParticipantParams(conversationId: conversationId, userId: userId),
    );

    return result.fold(
      (failure) {
        log('❌ [ChatViewModel] addParticipant: Error - ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedConversation) {
        log('✅ [ChatViewModel] addParticipant: Successfully added $userId');
        // Update selected conversation with new participant
        if (state.selectedConversation?.conversationId == conversationId) {
          state = state.copyWith(selectedConversation: updatedConversation);
        }
        // Update conversation in list
        final updatedConversations = state.conversations.map((conv) {
          if (conv.conversationId == conversationId) {
            return updatedConversation;
          }
          return conv;
        }).toList();
        state = state.copyWith(conversations: updatedConversations);
        return true;
      },
    );
  }

  /// Remove a participant from a group conversation
  Future<bool> removeParticipant(String conversationId, String userId) async {
    log(
      '🔁 [ChatViewModel] removeParticipant: Removing $userId from conversation=$conversationId',
    );

    final result = await _removeParticipantUsecase(
      RemoveParticipantParams(conversationId: conversationId, userId: userId),
    );

    return result.fold(
      (failure) {
        log('❌ [ChatViewModel] removeParticipant: Error - ${failure.message}');
        state = state.copyWith(
          status: ChatStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedConversation) {
        log(
          '✅ [ChatViewModel] removeParticipant: Successfully removed $userId',
        );
        // Update selected conversation without removed participant
        if (state.selectedConversation?.conversationId == conversationId) {
          state = state.copyWith(selectedConversation: updatedConversation);
        }
        // Update conversation in list
        final updatedConversations = state.conversations.map((conv) {
          if (conv.conversationId == conversationId) {
            return updatedConversation;
          }
          return conv;
        }).toList();
        state = state.copyWith(conversations: updatedConversations);
        return true;
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _userSessionService.getCurrentUserId();
  }

  /// Reset state
  void resetState() {
    state = const ChatState();
  }
}

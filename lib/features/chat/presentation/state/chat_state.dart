import 'package:equatable/equatable.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/domain/entities/message_entity.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  error,
  sending,
  messageSent,
  messageDeleted,
  typingIndicator,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ConversationEntity> conversations;
  final List<MessageEntity> messages;
  final ConversationEntity? selectedConversation;
  final String? errorMessage;
  final bool isTyping;
  final List<String> typingUsers; // List of user IDs currently typing
  final Set<String> onlineUsers; // Set of user IDs currently online
  final Map<String, DateTime> lastSeenMap; // Map of userId to last seen time
  final int totalMessagesCount;

  const ChatState({
    this.status = ChatStatus.initial,
    this.conversations = const [],
    this.messages = const [],
    this.selectedConversation,
    this.errorMessage,
    this.isTyping = false,
    this.typingUsers = const [],
    this.onlineUsers = const {},
    this.lastSeenMap = const {},
    this.totalMessagesCount = 0,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ConversationEntity>? conversations,
    List<MessageEntity>? messages,
    ConversationEntity? selectedConversation,
    String? errorMessage,
    bool? isTyping,
    List<String>? typingUsers,
    Set<String>? onlineUsers,
    Map<String, DateTime>? lastSeenMap,
    int? totalMessagesCount,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      selectedConversation: selectedConversation ?? this.selectedConversation,
      errorMessage: errorMessage ?? this.errorMessage,
      isTyping: isTyping ?? this.isTyping,
      typingUsers: typingUsers ?? this.typingUsers,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      lastSeenMap: lastSeenMap ?? this.lastSeenMap,
      totalMessagesCount: totalMessagesCount ?? this.totalMessagesCount,
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversations,
    messages,
    selectedConversation,
    errorMessage,
    isTyping,
    typingUsers,
    onlineUsers,
    lastSeenMap,
    totalMessagesCount,
  ];

  // Computed getters
  bool get isLoading => status == ChatStatus.loading;
  bool get hasError => status == ChatStatus.error;
}

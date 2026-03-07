import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import '../entities/message_entity.dart';
import '../entities/conversation_entity.dart';

abstract interface class IChatRepository {
  // Conversation Operations
  Future<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  );
  Future<Either<Failure, ConversationEntity>> getConversationById(
    String conversationId,
  );
  Future<Either<Failure, ConversationEntity>> getGroupChatByGroupId(
    String groupChatId,
  );
  Future<Either<Failure, ConversationEntity>> getGroupChatByTripId(
    String tripId,
  );
  Future<Either<Failure, ConversationEntity>> createOneOnOneConversation(
    String currentUserId,
    String otherUserId,
  );
  Future<Either<Failure, ConversationEntity>> createGroupConversation(
    String currentUserId,
    String groupName,
    List<String> participantIds,
    String? tripId,
  );

  // Message Operations
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  });
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    String senderId,
    String senderName,
    String content, {
    List<String>? imageUrls,
    String? replyToMessageId,
  });
  Future<Either<Failure, MessageEntity>> editMessage(
    String messageId,
    String newContent,
  );
  Future<Either<Failure, bool>> deleteMessage(String messageId);
  Future<Either<Failure, bool>> markAsRead(String messageId);
  Future<Either<Failure, bool>> markConversationAsRead(String conversationId);

  // Typing Indicators
  Future<Either<Failure, bool>> sendTypingIndicator(
    String conversationId,
    String userId,
  );

  // Group Management
  Future<Either<Failure, ConversationEntity>> addParticipant(
    String conversationId,
    String userId,
  );
  Future<Either<Failure, ConversationEntity>> removeParticipant(
    String conversationId,
    String userId,
  );

  // Search
  Future<Either<Failure, List<ConversationEntity>>> searchConversations(
    String userId,
    String query,
  );
  Future<Either<Failure, List<MessageEntity>>> searchMessages(
    String conversationId,
    String query,
  );
}

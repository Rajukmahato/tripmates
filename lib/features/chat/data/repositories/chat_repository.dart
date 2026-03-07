import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/services/connectivity/network_info.dart'
    as network_info;
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:tripmates/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:tripmates/features/chat/data/models/chat_api_model.dart';
import 'package:tripmates/features/chat/data/models/chat_hive_model.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/domain/entities/message_entity.dart';
import 'package:tripmates/features/chat/domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  final chatLocalDatasource = ref.read(chatLocalDatasourceProvider);
  final chatRemoteDatasource = ref.read(chatRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return ChatRepository(
    chatLocalDatasource: chatLocalDatasource,
    chatRemoteDatasource: chatRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class ChatRepository implements IChatRepository {
  final IChatLocalDataSource _chatLocalDataSource;
  final IChatRemoteDataSource _chatRemoteDataSource;
  final network_info.NetworkInfo _networkInfo;

  ChatRepository({
    required IChatLocalDataSource chatLocalDatasource,
    required IChatRemoteDataSource chatRemoteDatasource,
    required network_info.NetworkInfo networkInfo,
  }) : _chatLocalDataSource = chatLocalDatasource,
       _chatRemoteDataSource = chatRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteConversations = await _chatRemoteDataSource
            .getConversations(userId);
        final hiveModels = remoteConversations
            .map((model) => _apiModelToHiveModel(model))
            .toList();
        await _chatLocalDataSource.saveConversations(userId, hiveModels);
        final entities = remoteConversations
            .map((model) => _apiModelToEntity(model))
            .toList();
        return Right(entities);
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localConversations = await _chatLocalDataSource.getConversations(
          userId,
        );
        final entities = localConversations
            .map((model) => _hiveModelToEntity(model))
            .toList();
        return Right(entities);
      } catch (e) {
        return const Left(ApiFailure(message: 'No cached conversations'));
      }
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversationById(
    String conversationId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteConversation = await _chatRemoteDataSource
            .getConversationById(conversationId);
        if (remoteConversation != null) {
          final hiveModel = _apiModelToHiveModel(remoteConversation);
          await _chatLocalDataSource.saveConversation(hiveModel);
          return Right(_apiModelToEntity(remoteConversation));
        }
        return Left(ApiFailure(message: 'Conversation not found'));
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localConversation = await _chatLocalDataSource
            .getConversationById(conversationId);
        if (localConversation != null) {
          return Right(_hiveModelToEntity(localConversation));
        }
        return const Left(ApiFailure(message: 'Conversation not cached'));
      } catch (e) {
        return const Left(ApiFailure(message: 'Failed to get conversation'));
      }
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getGroupChatByGroupId(
    String groupChatId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteConversation = await _chatRemoteDataSource
            .getGroupChatByGroupId(groupChatId);
        if (remoteConversation != null) {
          final hiveModel = _apiModelToHiveModel(remoteConversation);
          await _chatLocalDataSource.saveConversation(hiveModel);
          return Right(_apiModelToEntity(remoteConversation));
        }
        return Left(ApiFailure(message: 'Group chat not found'));
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getGroupChatByTripId(
    String tripId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteConversation = await _chatRemoteDataSource
            .getGroupChatByTripId(tripId);
        if (remoteConversation != null) {
          final hiveModel = _apiModelToHiveModel(remoteConversation);
          await _chatLocalDataSource.saveConversation(hiveModel);
          return Right(_apiModelToEntity(remoteConversation));
        }
        return Left(ApiFailure(message: 'Group chat not found'));
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> createOneOnOneConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remoteConversation = await _chatRemoteDataSource.createOneOnOne(
        currentUserId,
        otherUserId,
      );
      final hiveModel = _apiModelToHiveModel(remoteConversation);
      await _chatLocalDataSource.saveConversation(hiveModel);
      return Right(_apiModelToEntity(remoteConversation));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> createGroupConversation(
    String currentUserId,
    String groupName,
    List<String> participantIds,
    String? tripId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remoteConversation = await _chatRemoteDataSource.createGroup(
        currentUserId,
        participantIds,
        groupName,
        null,
        tripId,
      );
      final hiveModel = _apiModelToHiveModel(remoteConversation);
      await _chatLocalDataSource.saveConversation(hiveModel);
      return Right(_apiModelToEntity(remoteConversation));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteMessages = await _chatRemoteDataSource.getMessages(
          conversationId,
          limit: limit,
          before: before,
        );
        final hiveModels = remoteMessages
            .map((model) => _chatApiToHiveModel(model))
            .toList();
        await _chatLocalDataSource.saveMessages(conversationId, hiveModels);
        final entities = remoteMessages
            .map((model) => _chatApiToEntity(model))
            .toList();
        return Right(entities);
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final localMessages = await _chatLocalDataSource.getMessages(
          conversationId,
        );
        final entities = localMessages
            .map((model) => _chatHiveToEntity(model))
            .toList();
        return Right(entities);
      } catch (e) {
        return const Left(ApiFailure(message: 'No cached messages'));
      }
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    String senderId,
    String senderName,
    String content, {
    List<String>? imageUrls,
    String? replyToMessageId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remoteMessage = await _chatRemoteDataSource.sendMessage(
        conversationId,
        senderId,
        senderName,
        content,
        imageUrls: imageUrls,
        replyToMessageId: replyToMessageId,
      );
      final hiveModel = _chatApiToHiveModel(remoteMessage);
      await _chatLocalDataSource.saveMessage(hiveModel);
      return Right(_chatApiToEntity(remoteMessage));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> editMessage(
    String messageId,
    String newContent,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remoteMessage = await _chatRemoteDataSource.editMessage(
        messageId,
        newContent,
      );
      return Right(_chatApiToEntity(remoteMessage));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMessage(String messageId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _chatRemoteDataSource.deleteMessage(messageId);
      return const Right(true);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String messageId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _chatRemoteDataSource.markAsRead(messageId);
      return const Right(true);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markConversationAsRead(
    String conversationId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _chatRemoteDataSource.markConversationAsRead(conversationId);
      return const Right(true);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendTypingIndicator(
    String conversationId,
    String userId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await _chatRemoteDataSource.sendTypingIndicator(conversationId, userId);
      return const Right(true);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> addParticipant(
    String conversationId,
    String userId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remoteConversation = await _chatRemoteDataSource.addParticipant(
        conversationId,
        userId,
      );
      final hiveModel = _apiModelToHiveModel(remoteConversation);
      await _chatLocalDataSource.saveConversation(hiveModel);
      return Right(_apiModelToEntity(remoteConversation));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> removeParticipant(
    String conversationId,
    String userId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remoteConversation = await _chatRemoteDataSource.removeParticipant(
        conversationId,
        userId,
      );
      final hiveModel = _apiModelToHiveModel(remoteConversation);
      await _chatLocalDataSource.saveConversation(hiveModel);
      return Right(_apiModelToEntity(remoteConversation));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> searchConversations(
    String userId,
    String query,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remoteConversations = await _chatRemoteDataSource
          .searchConversations(userId, query);
      final entities = remoteConversations
          .map((model) => _apiModelToEntity(model))
          .toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> searchMessages(
    String conversationId,
    String query,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remoteMessages = await _chatRemoteDataSource.searchMessages(
        conversationId,
        query,
      );
      final entities = remoteMessages
          .map((model) => _chatApiToEntity(model))
          .toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // Helper methods for converting between models and entities

  ConversationEntity _apiModelToEntity(ConversationApiModel model) {
    return ConversationEntity(
      conversationId: model.conversationId,
      name: model.name,
      participantIds: model.participantIds,
      type: model.type == 'group'
          ? ConversationType.group
          : ConversationType.oneOnOne,
      lastMessage: model.lastMessage,
      unreadCount: model.unreadCount ?? 0,
      groupProfilePicture: model.groupProfilePicture,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
      lastMessageAt: model.lastMessageAt != null
          ? DateTime.parse(model.lastMessageAt!)
          : null,
      otherUserProfilePicture: model.otherUserProfilePicture, // From API model
      otherUserName: model.otherUserName, // From API model
      tripId: model.tripId, // From API model for group chats
    );
  }

  ConversationHiveModel _apiModelToHiveModel(ConversationApiModel model) {
    return ConversationHiveModel(
      conversationId: model.conversationId,
      name: model.name,
      participantIds: model.participantIds,
      type: model.type,
      lastMessage: model.lastMessage,
      unreadCount: model.unreadCount ?? 0,
      groupProfilePicture: model.groupProfilePicture,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
      lastMessageAt: model.lastMessageAt != null
          ? DateTime.parse(model.lastMessageAt!)
          : null,
      otherUserProfilePicture: model.otherUserProfilePicture,
      otherUserName: model.otherUserName,
    );
  }

  ConversationEntity _hiveModelToEntity(ConversationHiveModel model) {
    return ConversationEntity(
      conversationId: model.conversationId,
      name: model.name,
      participantIds: model.participantIds,
      type: model.type == 'group'
          ? ConversationType.group
          : ConversationType.oneOnOne,
      lastMessage: model.lastMessage,
      unreadCount: model.unreadCount,
      groupProfilePicture: model.groupProfilePicture,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      lastMessageAt: model.lastMessageAt,
      otherUserProfilePicture: model.otherUserProfilePicture,
      otherUserName: model.otherUserName,
    );
  }

  MessageEntity _chatApiToEntity(ChatApiModel model) {
    return MessageEntity(
      messageId: model.messageId ?? '',
      conversationId: model.conversationId,
      senderId: model.senderId,
      senderName: model.senderName,
      senderProfilePicture: model.senderProfilePicture,
      content: model.content,
      createdAt: DateTime.parse(model.createdAt),
      editedAt: model.editedAt != null ? DateTime.parse(model.editedAt!) : null,
      isRead: model.isRead ?? false,
      imageUrls: model.imageUrls,
      replyToMessageId: model.replyToMessageId,
    );
  }

  ChatHiveModel _chatApiToHiveModel(ChatApiModel model) {
    return ChatHiveModel(
      messageId: model.messageId ?? '',
      conversationId: model.conversationId,
      senderId: model.senderId,
      senderName: model.senderName,
      senderProfilePicture: model.senderProfilePicture,
      content: model.content,
      createdAt: DateTime.parse(model.createdAt),
      editedAt: model.editedAt != null ? DateTime.parse(model.editedAt!) : null,
      isRead: model.isRead ?? false,
      imageUrls: model.imageUrls,
      replyToMessageId: model.replyToMessageId,
    );
  }

  MessageEntity _chatHiveToEntity(ChatHiveModel model) {
    return MessageEntity(
      messageId: model.messageId,
      conversationId: model.conversationId,
      senderId: model.senderId,
      senderName: model.senderName,
      senderProfilePicture: model.senderProfilePicture,
      content: model.content,
      createdAt: model.createdAt,
      editedAt: model.editedAt,
      isRead: model.isRead,
      imageUrls: model.imageUrls,
      replyToMessageId: model.replyToMessageId,
    );
  }
}

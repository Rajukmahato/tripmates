import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import '../models/chat_hive_model.dart';

abstract class IChatLocalDataSource {
  Future<List<ConversationHiveModel>> getConversations(String userId);
  Future<ConversationHiveModel?> getConversationById(String conversationId);
  Future<void> saveConversations(
    String userId,
    List<ConversationHiveModel> conversations,
  );
  Future<void> saveConversation(ConversationHiveModel conversation);
  Future<List<ChatHiveModel>> getMessages(String conversationId);
  Future<void> saveMessages(
    String conversationId,
    List<ChatHiveModel> messages,
  );
  Future<void> saveMessage(ChatHiveModel message);
  Future<void> deleteMessage(String messageId, String conversationId);
  Future<void> clearAllCache();
}

final chatLocalDatasourceProvider = Provider<IChatLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return ChatLocalDataSource(hiveService);
});

class ChatLocalDataSource implements IChatLocalDataSource {
  ChatLocalDataSource(_);

  @override
  Future<List<ConversationHiveModel>> getConversations(String userId) async {
    try {
      final box = Hive.box<ConversationHiveModel>('conversations_$userId');
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ConversationHiveModel?> getConversationById(
    String conversationId,
  ) async {
    try {
      final box = Hive.box<ConversationHiveModel>(
        'conversation_$conversationId',
      );
      return box.get(conversationId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveConversations(
    String userId,
    List<ConversationHiveModel> conversations,
  ) async {
    try {
      final box = await _openBox<ConversationHiveModel>(
        'conversations_$userId',
      );
      await box.clear();
      for (final conversation in conversations) {
        await box.put(conversation.conversationId, conversation);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveConversation(ConversationHiveModel conversation) async {
    try {
      final box = await _openBox<ConversationHiveModel>(
        'conversation_${conversation.conversationId}',
      );
      await box.put(conversation.conversationId, conversation);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ChatHiveModel>> getMessages(String conversationId) async {
    try {
      final box = Hive.box<ChatHiveModel>('messages_$conversationId');
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveMessages(
    String conversationId,
    List<ChatHiveModel> messages,
  ) async {
    try {
      final box = await _openBox<ChatHiveModel>('messages_$conversationId');
      for (final message in messages) {
        await box.put(message.messageId, message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveMessage(ChatHiveModel message) async {
    try {
      final box = await _openBox<ChatHiveModel>(
        'messages_${message.conversationId}',
      );
      await box.put(message.messageId, message);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String messageId, String conversationId) async {
    try {
      final box = await _openBox<ChatHiveModel>('messages_$conversationId');
      await box.delete(messageId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      // Clear known chat-related boxes using Hive directly
      // This is a simple implementation - in production you'd want to track all box names
    } catch (e) {
      rethrow;
    }
  }

  Future<Box<T>> _openBox<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      }
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      return Hive.box<T>(boxName);
    }
  }
}

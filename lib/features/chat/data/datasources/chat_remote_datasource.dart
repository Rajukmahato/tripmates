import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import '../models/chat_api_model.dart';

abstract class IChatRemoteDataSource {
  Future<List<ConversationApiModel>> getConversations(String userId);
  Future<ConversationApiModel?> getConversationById(String conversationId);
  Future<ConversationApiModel?> getGroupChatByGroupId(String groupChatId);
  Future<ConversationApiModel?> getGroupChatByTripId(String tripId);
  Future<ConversationApiModel> createOneOnOne(String userId1, String userId2);
  Future<ConversationApiModel> createGroup(
    String createdBy,
    List<String> participantIds,
    String groupName,
    String? groupProfilePicture,
    String? tripId,
  );
  Future<List<ChatApiModel>> getMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  });
  Future<ChatApiModel> sendMessage(
    String conversationId,
    String senderId,
    String senderName,
    String content, {
    List<String>? imageUrls,
    String? replyToMessageId,
  });
  Future<ChatApiModel> editMessage(String messageId, String newContent);
  Future<void> deleteMessage(String messageId);
  Future<void> markAsRead(String messageId);
  Future<void> sendTypingIndicator(String conversationId, String userId);
  Future<void> markConversationAsRead(String conversationId);
  Future<ConversationApiModel> addParticipant(
    String conversationId,
    String userId,
  );
  Future<ConversationApiModel> removeParticipant(
    String conversationId,
    String userId,
  );
  Future<List<ConversationApiModel>> searchConversations(
    String userId,
    String query,
  );
  Future<List<ChatApiModel>> searchMessages(
    String conversationId,
    String query,
  );
}

final chatRemoteDatasourceProvider = Provider<IChatRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return ChatRemoteDataSource(apiClient, userSessionService);
});

class ChatRemoteDataSource implements IChatRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  ChatRemoteDataSource(this._apiClient, this._userSessionService);

  @override
  Future<List<ConversationApiModel>> getConversations(String userId) async {
    try {
      log(
        '📱 [ChatRemoteDataSource] getConversations: Fetching for userId=$userId',
      );

      // Fetch both private and group conversations in parallel
      final privateConversationsFuture = _getPrivateConversations();
      final groupConversationsFuture = _getGroupConversations();

      final results = await Future.wait([
        privateConversationsFuture,
        groupConversationsFuture,
      ]);

      final privateConversations = results[0];
      final groupConversations = results[1];

      // Combine both lists
      final allConversations = [...privateConversations, ...groupConversations];

      log(
        '✅ [ChatRemoteDataSource] Found ${privateConversations.length} private + ${groupConversations.length} group = ${allConversations.length} total conversations',
      );

      return allConversations;
    } catch (e) {
      log('❌ [ChatRemoteDataSource] Unexpected error: $e');
      throw ApiFailure(message: e.toString());
    }
  }

  Future<List<ConversationApiModel>> _getPrivateConversations() async {
    try {
      log('📍 [ChatRemoteDataSource] Fetching private conversations');

      final response = await _apiClient.get(ApiEndpoints.chatConversations);
      log(
        '✅ [ChatRemoteDataSource] Private response status: ${response.statusCode}',
      );

      final rawData = response.data;
      final dynamic payload = rawData is Map<String, dynamic>
          ? (rawData['data'] ?? rawData['conversations'] ?? rawData)
          : rawData;

      final List<dynamic> items = payload is List
          ? payload
          : (payload is Map<String, dynamic> &&
                payload['conversations'] is List)
          ? payload['conversations'] as List
          : const [];

      final conversations = items
          .whereType<Map<String, dynamic>>()
          .map(ConversationApiModel.fromJson)
          .toList();

      log(
        '📊 [ChatRemoteDataSource] Parsed ${conversations.length} private conversations',
      );

      return conversations;
    } on DioException catch (e) {
      log(
        '❌ [ChatRemoteDataSource] DioException in private conversations: ${e.message}',
      );
      // Return empty list instead of throwing to allow group chats to still load
      return [];
    } catch (e) {
      log('❌ [ChatRemoteDataSource] Error in private conversations: $e');
      return [];
    }
  }

  Future<List<ConversationApiModel>> _getGroupConversations() async {
    try {
      log('📍 [ChatRemoteDataSource] Fetching group conversations');

      final response = await _apiClient.get(ApiEndpoints.chatGroups);
      log(
        '✅ [ChatRemoteDataSource] Group response status: ${response.statusCode}',
      );

      final rawData = response.data;
      final dynamic payload = rawData is Map<String, dynamic>
          ? (rawData['data'] ?? rawData['groups'] ?? rawData)
          : rawData;

      final List<dynamic> items = payload is List
          ? payload
          : (payload is Map<String, dynamic> && payload['groups'] is List)
          ? payload['groups'] as List
          : const [];

      final conversations = items
          .whereType<Map<String, dynamic>>()
          .map(ConversationApiModel.fromJson)
          .toList();

      log(
        '📊 [ChatRemoteDataSource] Parsed ${conversations.length} group conversations',
      );

      return conversations;
    } on DioException catch (e) {
      log(
        '❌ [ChatRemoteDataSource] DioException in group conversations: ${e.message}',
      );
      // Return empty list instead of throwing to allow private chats to still load
      return [];
    } catch (e) {
      log('❌ [ChatRemoteDataSource] Error in group conversations: $e');
      return [];
    }
  }

  @override
  Future<ConversationApiModel?> getConversationById(
    String conversationId,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.chatConversations}/$conversationId',
      );
      if (response.data['data'] == null) return null;
      return ConversationApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message:
            e.response?.data['message'] ?? 'Failed to get conversation details',
      );
    }
  }

  ConversationApiModel _mapGroupChatToConversation(
    Map<String, dynamic> groupChat,
  ) {
    String? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value['_id'] as String?;
      return value as String?;
    }

    List<String> parseMembers(dynamic value) {
      if (value is List) {
        return value
            .map((item) => extractId(item) ?? item.toString())
            .where((id) => id.isNotEmpty)
            .toList();
      }
      return const [];
    }

    int? parseIntValue(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    }

    String? extractLastMessageContent(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return value['content'] as String?;
      }
      return null;
    }

    final groupChatId =
        groupChat['groupChatId'] as String? ??
        groupChat['_id'] as String? ??
        '';
    final trip = groupChat['trip'];
    String? tripId;
    String? groupName;
    String? groupProfilePicture;

    if (trip is Map<String, dynamic>) {
      tripId = trip['_id'] as String?;
      groupName =
          trip['destination'] as String? ??
          trip['title'] as String? ??
          'Trip Group';
      if (trip['images'] is List && (trip['images'] as List).isNotEmpty) {
        groupProfilePicture = (trip['images'] as List).first?.toString();
      } else if (trip['image'] != null) {
        groupProfilePicture = trip['image'] as String?;
      }
    } else if (trip is String) {
      tripId = trip;
    }

    final createdAt =
        groupChat['createdAt'] as String? ?? DateTime.now().toIso8601String();
    final updatedAt = groupChat['updatedAt'] as String? ?? createdAt;
    final lastMessageAt = groupChat['lastMessageAt'] as String? ?? createdAt;

    return ConversationApiModel.fromJson({
      'conversationId': groupChatId,
      'name': groupName,
      'participantIds': parseMembers(groupChat['members']),
      'type': 'group',
      'lastMessage': extractLastMessageContent(groupChat['lastMessage']),
      'unreadCount': parseIntValue(groupChat['unreadCount']) ?? 0,
      'groupProfilePicture': groupProfilePicture,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastMessageAt': lastMessageAt,
      'tripId': tripId,
    });
  }

  @override
  Future<ConversationApiModel?> getGroupChatByGroupId(
    String groupChatId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.chatGroupByGroupId(groupChatId),
      );

      final raw = response.data;
      final data = raw is Map<String, dynamic> ? (raw['data'] ?? raw) : raw;

      if (data is Map<String, dynamic>) {
        return _mapGroupChatToConversation(data);
      }
      return null;
    } on DioException catch (e) {
      throw ApiFailure(
        message:
            e.response?.data['message'] ?? 'Failed to get group chat by id',
      );
    }
  }

  @override
  Future<ConversationApiModel?> getGroupChatByTripId(String tripId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.chatGroupByTripId(tripId),
      );

      final raw = response.data;
      final data = raw is Map<String, dynamic> ? (raw['data'] ?? raw) : raw;

      if (data is Map<String, dynamic>) {
        return _mapGroupChatToConversation(data);
      }
      return null;
    } on DioException catch (e) {
      throw ApiFailure(
        message:
            e.response?.data['message'] ?? 'Failed to get group chat by trip',
      );
    }
  }

  @override
  Future<ConversationApiModel> createOneOnOne(
    String userId1,
    String userId2,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chatConversations,
        data: {'userId1': userId1, 'userId2': userId2, 'type': 'oneOnOne'},
      );
      return ConversationApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to create chat',
      );
    }
  }

  @override
  Future<ConversationApiModel> createGroup(
    String createdBy,
    List<String> participantIds,
    String groupName,
    String? groupProfilePicture,
    String? tripId,
  ) async {
    try {
      log(
        '🆕 [CreateGroup] Request - tripId: $tripId, groupName: $groupName, participants: ${participantIds.length}',
      );
      final response = await _apiClient.post(
        ApiEndpoints.chatGroups,
        data: {
          'createdBy': createdBy,
          'participantIds': participantIds,
          'groupName': groupName,
          'groupProfilePicture': groupProfilePicture,
          'tripId': tripId,
        },
      );
      log('✅ [CreateGroup] Response status: ${response.statusCode}');
      log('📦 [CreateGroup] Response data: ${response.data}');

      final data = response.data['data'] as Map<String, dynamic>;
      log('🔍 [CreateGroup] Parsed data keys: ${data.keys.toList()}');
      log('🔍 [CreateGroup] groupId: ${data['groupId']}');
      log('🔍 [CreateGroup] tripId: ${data['tripId']}');

      // Transform group creation response to ConversationApiModel format
      // Backend returns: {groupId, tripId, members, createdBy, createdAt}
      // We need to map it to ConversationApiModel format
      final transformedData = <String, dynamic>{
        'conversationId': data['groupId'], // Map groupId to conversationId
        'type': 'group', // Explicitly set type to group
        'participantIds':
            data['members'] ??
            participantIds, // Use members from response or sent participantIds
        'name': groupName,
        'groupProfilePicture': groupProfilePicture,
        'tripId': data['tripId'],
        'createdBy': data['createdBy'],
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'lastMessage': null,
        'unreadCount': 0,
      };

      log('🔄 [CreateGroup] Transformed data: $transformedData');

      return ConversationApiModel.fromJson(transformedData);
    } on DioException catch (e) {
      log('❌ [CreateGroup] Error: ${e.message}');
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to create group chat',
      );
    }
  }

  @override
  Future<List<ChatApiModel>> getMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      // Determine the correct endpoint based on conversation type
      String endpoint;

      // Check if it's a one-on-one conversation (format: userId1_userId2)
      if (conversationId.contains('_')) {
        // Extract the other user's ID from the conversationId
        final currentUserId = _userSessionService.getCurrentUserId();
        if (currentUserId == null) {
          throw ApiFailure(message: 'User not authenticated');
        }

        final userIds = conversationId.split('_');
        final otherUserId = userIds.firstWhere(
          (id) => id != currentUserId,
          orElse: () => userIds[0],
        );

        // Use the private chat endpoint
        endpoint = ApiEndpoints.chatMessages(otherUserId);
      } else {
        // It's a group chat, use the group messages endpoint
        endpoint = ApiEndpoints.chatGroupMessages(conversationId);
      }

      log('📱 Fetching messages from: $endpoint');
      final response = await _apiClient.get(
        endpoint,
        queryParameters: {
          'limit': limit,
          if (before != null) 'before': before.toIso8601String(),
        },
      );

      log('✅ Response status: ${response.statusCode}');
      log('📦 Response data keys: ${response.data?.keys}');

      // Safely extract messages from the nested structure
      if (response.data == null) {
        throw ApiFailure(message: 'Empty response from server');
      }

      final responseData = response.data['data'];
      if (responseData == null) {
        throw ApiFailure(message: 'No data field in response');
      }

      if (responseData is! Map<String, dynamic>) {
        throw ApiFailure(message: 'Invalid response format: data is not a Map');
      }

      final messagesList = responseData['messages'];
      if (messagesList == null) {
        log('⚠️  No messages field in response, returning empty list');
        return [];
      }

      if (messagesList is! List) {
        throw ApiFailure(
          message: 'Invalid response format: messages is not a List',
        );
      }

      log('📨 Found ${messagesList.length} messages');

      final messages = messagesList.map((e) {
        try {
          return ChatApiModel.fromJson(e as Map<String, dynamic>);
        } catch (parseError) {
          log('❌ Error parsing message: $parseError');
          log('📄 Message data: $e');
          rethrow;
        }
      }).toList();

      log('✅ Successfully parsed ${messages.length} messages');
      return messages;
    } on ApiFailure {
      rethrow;
    } on DioException catch (e) {
      log('❌ DioException: ${e.message}');
      log('📄 Response data: ${e.response?.data}');
      throw ApiFailure(
        message:
            e.response?.data['message'] ??
            'Failed to load messages: ${e.message}',
      );
    } catch (e, stackTrace) {
      log('❌ Unexpected error: $e');
      log('📚 Stack trace: $stackTrace');
      throw ApiFailure(message: 'Failed to load messages: $e');
    }
  }

  @override
  Future<ChatApiModel> sendMessage(
    String conversationId,
    String senderId,
    String senderName,
    String content, {
    List<String>? imageUrls,
    String? replyToMessageId,
  }) async {
    try {
      // Determine the correct endpoint based on conversation type
      String endpoint;
      Map<String, dynamic> data;

      // Check if it's a one-on-one conversation (format: userId1_userId2)
      if (conversationId.contains('_')) {
        // Extract the other user's ID from the conversationId
        final currentUserId = _userSessionService.getCurrentUserId();
        if (currentUserId == null) {
          throw ApiFailure(message: 'User not authenticated');
        }

        final userIds = conversationId.split('_');
        final receiverId = userIds.firstWhere(
          (id) => id != currentUserId,
          orElse: () => userIds[0],
        );

        // Use the private chat endpoint
        endpoint = ApiEndpoints.chatSendMessage;
        data = {
          'receiverId': receiverId,
          'content': content,
          if (imageUrls != null) 'imageUrls': imageUrls,
          if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        };
      } else {
        // It's a group chat - only send content, backend extracts sender from auth
        endpoint = ApiEndpoints.chatGroupMessages(conversationId);
        data = {
          'content': content,
          if (imageUrls != null) 'imageUrls': imageUrls,
          if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        };
      }

      final response = await _apiClient.post(endpoint, data: data);
      return ChatApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to send message',
      );
    }
  }

  @override
  Future<ChatApiModel> editMessage(String messageId, String newContent) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.chatConversations}/messages/$messageId',
        data: {'content': newContent},
      );
      return ChatApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to edit message',
      );
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _apiClient.delete(
        '${ApiEndpoints.chatConversations}/messages/$messageId',
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to delete message',
      );
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    try {
      await _apiClient.patch(
        '${ApiEndpoints.chatConversations}/messages/$messageId/read',
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to mark as read',
      );
    }
  }

  @override
  Future<void> sendTypingIndicator(String conversationId, String userId) async {
    try {
      await _apiClient.post(
        '${ApiEndpoints.chatConversations}/$conversationId/typing',
        data: {'userId': userId},
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message:
            e.response?.data['message'] ?? 'Failed to send typing indicator',
      );
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _apiClient.patch(
        '${ApiEndpoints.chatConversations}/$conversationId/read',
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message:
            e.response?.data['message'] ??
            'Failed to mark conversation as read',
      );
    }
  }

  @override
  Future<ConversationApiModel> addParticipant(
    String conversationId,
    String userId,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.chatConversations}/$conversationId/participants',
        data: {'userId': userId},
      );
      return ConversationApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to add participant',
      );
    }
  }

  @override
  Future<ConversationApiModel> removeParticipant(
    String conversationId,
    String userId,
  ) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.chatConversations}/$conversationId/participants/$userId',
      );
      return ConversationApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to remove participant',
      );
    }
  }

  @override
  Future<List<ConversationApiModel>> searchConversations(
    String userId,
    String query,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.chatConversations}/search',
        queryParameters: {'userId': userId, 'query': query},
      );
      final conversations = (response.data['data'] as List)
          .map((e) => ConversationApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return conversations;
    } on DioException catch (e) {
      throw ApiFailure(
        message:
            e.response?.data['message'] ?? 'Failed to search conversations',
      );
    }
  }

  @override
  Future<List<ChatApiModel>> searchMessages(
    String conversationId,
    String query,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.chatConversations}/$conversationId/messages/search',
        queryParameters: {'query': query},
      );
      final messages = (response.data['data'] as List)
          .map((e) => ChatApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return messages;
    } on DioException catch (e) {
      throw ApiFailure(
        message: e.response?.data['message'] ?? 'Failed to search messages',
      );
    }
  }
}

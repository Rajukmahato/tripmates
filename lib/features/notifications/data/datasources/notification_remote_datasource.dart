import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/notifications/data/models/notification_model.dart';

/// Remote data source for notifications API
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String notificationId);

  Future<void> deleteAllNotifications();
}

/// Implementation of NotificationRemoteDataSource
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      };

      final response = await apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['data'] ?? response.data['notifications'] ?? [];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load notifications',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.notificationUnreadCount,
      );

      if (response.statusCode == 200) {
        return response.data['count'] ?? response.data['unreadCount'] ?? 0;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get unread count',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.notificationMarkAsRead(notificationId),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark as read',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await apiClient.put(ApiEndpoints.notificationReadAll);

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark all as read',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await apiClient.delete('/notifications/$notificationId');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete notification',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      final response = await apiClient.delete('/notifications/all');

      if (response.statusCode != 200) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to delete all notifications',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

/// Riverpod provider for NotificationRemoteDataSource
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return NotificationRemoteDataSourceImpl(apiClient: apiClient);
    });

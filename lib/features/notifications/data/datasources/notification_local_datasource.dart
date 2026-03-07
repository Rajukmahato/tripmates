import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/notifications/data/models/notification_hive_model.dart';

/// Local data source for notifications using Hive
abstract class NotificationLocalDataSource {
  Future<List<NotificationHiveModel>> getCachedNotifications();
  Future<void> cacheNotifications(List<NotificationHiveModel> notifications);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> clearCache();
}

/// Implementation of NotificationLocalDataSource
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String boxName = HiveTableConstant.notificationBoxName;
  final HiveInterface hive;

  NotificationLocalDataSourceImpl({required this.hive});

  Future<Box<NotificationHiveModel>> _openBox() {
    return hive.openBox<NotificationHiveModel>(boxName);
  }

  @override
  Future<List<NotificationHiveModel>> getCachedNotifications() async {
    try {
      final box = await _openBox();
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached notifications');
    }
  }

  @override
  Future<void> cacheNotifications(
    List<NotificationHiveModel> notifications,
  ) async {
    try {
      final box = await _openBox();
      await box.clear();
      for (var notification in notifications) {
        await box.put(notification.id, notification);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache notifications');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final box = await _openBox();
      final current = box.get(notificationId);
      if (current == null || current.isRead) {
        return;
      }

      await box.put(
        notificationId,
        NotificationHiveModel(
          id: current.id,
          userId: current.userId,
          type: current.type,
          title: current.title,
          message: current.message,
          data: current.data,
          isRead: true,
          createdAt: current.createdAt,
          readAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to mark notification as read');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final box = await _openBox();
      final now = DateTime.now();
      for (final notification in box.values) {
        if (!notification.isRead) {
          await box.put(
            notification.id,
            NotificationHiveModel(
              id: notification.id,
              userId: notification.userId,
              type: notification.type,
              title: notification.title,
              message: notification.message,
              data: notification.data,
              isRead: true,
              createdAt: notification.createdAt,
              readAt: now,
            ),
          );
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to mark all notifications as read');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final box = await _openBox();
      await box.delete(notificationId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete cached notification');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await _openBox();
      await box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear notification cache');
    }
  }
}

/// Riverpod provider for NotificationLocalDataSource
final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>(
      (ref) => NotificationLocalDataSourceImpl(hive: Hive),
    );

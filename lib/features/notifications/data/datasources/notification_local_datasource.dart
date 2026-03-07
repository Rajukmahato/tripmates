import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/notifications/data/models/notification_hive_model.dart';

/// Local data source for notifications using Hive
abstract class NotificationLocalDataSource {
  Future<List<NotificationHiveModel>> getCachedNotifications();
  Future<void> cacheNotifications(List<NotificationHiveModel> notifications);
  Future<void> clearCache();
}

/// Implementation of NotificationLocalDataSource
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String boxName = 'notifications';
  final HiveInterface hive;

  NotificationLocalDataSourceImpl({required this.hive});

  @override
  Future<List<NotificationHiveModel>> getCachedNotifications() async {
    try {
      final box = await hive.openBox<NotificationHiveModel>(boxName);
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
      final box = await hive.openBox<NotificationHiveModel>(boxName);
      await box.clear();
      for (var notification in notifications) {
        await box.put(notification.id, notification);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache notifications');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await hive.openBox<NotificationHiveModel>(boxName);
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

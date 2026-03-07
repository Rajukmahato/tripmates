import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/notifications/domain/entities/notification_entity.dart';

/// Abstract repository for notification operations
abstract class NotificationRepository {
  /// Get all notifications for the current user
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  });

  /// Get unread notification count
  Future<Either<Failure, int>> getUnreadCount();

  /// Mark a notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Delete all notifications
  Future<Either<Failure, void>> deleteAllNotifications();

  /// Get cached notifications (for offline access)
  Future<Either<Failure, List<NotificationEntity>>> getCachedNotifications();

  /// Cache notifications locally
  Future<Either<Failure, void>> cacheNotifications(
    List<NotificationEntity> notifications,
  );
}

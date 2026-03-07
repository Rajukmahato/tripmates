import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:tripmates/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:tripmates/features/notifications/data/models/notification_hive_model.dart';
import 'package:tripmates/features/notifications/domain/entities/notification_entity.dart';
import 'package:tripmates/features/notifications/domain/repositories/notification_repository.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
        type: type,
      );

      // Cache notifications on first page (with error handling)
      if (page == 1) {
        try {
          final hiveModels = notifications
              .map(
                (model) => NotificationHiveModel.fromEntity(model.toEntity()),
              )
              .toList();
          await localDataSource.cacheNotifications(hiveModels);
        } catch (cacheError) {
          // Log cache error but don't fail - proceed with returning data
          // print('⚠️ Cache error (non-critical): $cacheError');
        }
      }

      // Return notifications directly since NotificationModel extends NotificationEntity
      return Right(notifications.cast<NotificationEntity>());
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      // Log the actual error for debugging
      // print('❌ Notification repository error: $e');
      return Left(ApiFailure(message: 'Failed to get notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get unread count'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to mark as read'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to mark all as read'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to delete notification'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    try {
      await remoteDataSource.deleteAllNotifications();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to delete all notifications'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>>
  getCachedNotifications() async {
    try {
      final cachedNotifications = await localDataSource
          .getCachedNotifications();
      return Right(
        cachedNotifications.map((model) => model.toEntity()).toList(),
      );
    } on CacheException catch (e) {
      return Left(LocalDatabaseFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: 'Failed to get cached notifications'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cacheNotifications(
    List<NotificationEntity> notifications,
  ) async {
    try {
      final hiveModels = notifications
          .map((entity) => NotificationHiveModel.fromEntity(entity))
          .toList();
      await localDataSource.cacheNotifications(hiveModels);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(LocalDatabaseFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: 'Failed to cache notifications'),
      );
    }
  }
}

/// Riverpod provider for NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  final localDataSource = ref.watch(notificationLocalDataSourceProvider);
  return NotificationRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

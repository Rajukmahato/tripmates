import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/core/services/connectivity/network_info.dart'
    show NetworkInfo;
import 'package:tripmates/core/services/offline/offline_operations_queue.dart';
import 'package:tripmates/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:tripmates/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:tripmates/features/notifications/data/models/notification_hive_model.dart';
import 'package:tripmates/features/notifications/domain/entities/notification_entity.dart';
import 'package:tripmates/features/notifications/domain/repositories/notification_repository.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final OfflineOperationsQueue operationsQueue;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.operationsQueue,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final notifications = await remoteDataSource.getNotifications(
          page: page,
          limit: limit,
          type: type,
        );

        if (page == 1) {
          try {
            final hiveModels = notifications
                .map(
                  (model) => NotificationHiveModel.fromEntity(model.toEntity()),
                )
                .toList();
            await localDataSource.cacheNotifications(hiveModels);
          } catch (_) {
            // Non-critical cache failure.
          }
        }

        return Right(notifications.cast<NotificationEntity>());
      } on ServerException catch (e) {
        // Remote failed, fallback to cached notifications.
        try {
          final cachedNotifications = await localDataSource
              .getCachedNotifications();
          return Right(
            cachedNotifications.map((model) => model.toEntity()).toList(),
          );
        } catch (_) {
          return Left(ApiFailure(message: e.message));
        }
      } catch (e) {
        try {
          final cachedNotifications = await localDataSource
              .getCachedNotifications();
          return Right(
            cachedNotifications.map((model) => model.toEntity()).toList(),
          );
        } catch (_) {
          return Left(ApiFailure(message: 'Failed to get notifications: $e'));
        }
      }
    }

    // Offline path
    try {
      final cachedNotifications = await localDataSource
          .getCachedNotifications();
      return Right(
        cachedNotifications.map((model) => model.toEntity()).toList(),
      );
    } on CacheException {
      return const Left(
        NetworkFailure(
          message: 'No internet connection and no cached notifications',
        ),
      );
    } catch (e) {
      return Left(
        NetworkFailure(
          message: 'Offline and failed to load cached notifications: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final count = await remoteDataSource.getUnreadCount();
        return Right(count);
      } on ServerException catch (e) {
        try {
          final cachedNotifications = await localDataSource
              .getCachedNotifications();
          final unreadCount = cachedNotifications
              .where((item) => !item.isRead)
              .length;
          return Right(unreadCount);
        } catch (_) {
          return Left(ApiFailure(message: e.message));
        }
      }
    }

    // Offline path (or remote failed fallback)
    try {
      final cachedNotifications = await localDataSource
          .getCachedNotifications();
      final unreadCount = cachedNotifications
          .where((item) => !item.isRead)
          .length;
      return Right(unreadCount);
    } catch (_) {
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    final isConnected = await networkInfo.isConnected;

    try {
      await localDataSource.markAsRead(notificationId);
    } catch (_) {
      // Local cache mutation failures should not block the operation.
    }

    if (!isConnected) {
      try {
        await operationsQueue.queueOperation(
          id: 'notification_mark_read_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'notification',
          type: OperationType.update,
          data: {'action': 'mark_as_read', 'notificationId': notificationId},
        );
        return const Right(null);
      } catch (e) {
        return Left(ApiFailure(message: 'Failed to queue mark-as-read: $e'));
      }
    }

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
    final isConnected = await networkInfo.isConnected;

    try {
      await localDataSource.markAllAsRead();
    } catch (_) {
      // Local cache mutation failures should not block the operation.
    }

    if (!isConnected) {
      try {
        await operationsQueue.queueOperation(
          id: 'notification_mark_all_read_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'notification',
          type: OperationType.update,
          data: {'action': 'mark_all_as_read'},
        );
        return const Right(null);
      } catch (e) {
        return Left(
          ApiFailure(message: 'Failed to queue mark-all-as-read: $e'),
        );
      }
    }

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
    final isConnected = await networkInfo.isConnected;

    try {
      await localDataSource.deleteNotification(notificationId);
    } catch (_) {
      // Local cache mutation failures should not block the operation.
    }

    if (!isConnected) {
      try {
        await operationsQueue.queueOperation(
          id: 'notification_delete_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'notification',
          type: OperationType.delete,
          data: {
            'action': 'delete_notification',
            'notificationId': notificationId,
          },
        );
        return const Right(null);
      } catch (e) {
        return Left(
          ApiFailure(message: 'Failed to queue delete-notification: $e'),
        );
      }
    }

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
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      try {
        await operationsQueue.queueOperation(
          id: 'notification_delete_all_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'notification',
          type: OperationType.delete,
          data: {'action': 'delete_all_notifications'},
        );
        await localDataSource.clearCache();
        return const Right(null);
      } catch (e) {
        return Left(
          ApiFailure(message: 'Failed to queue delete-all-notifications: $e'),
        );
      }
    }

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
  final networkInfo = ref.watch(networkInfoProvider);
  final operationsQueue = ref.watch(offlineOperationsQueueProvider);
  return NotificationRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
    operationsQueue: operationsQueue,
  );
});

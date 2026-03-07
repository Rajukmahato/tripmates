import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/notifications/domain/repositories/notification_repository.dart';

/// Use case for deleting a notification
class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.deleteNotification(notificationId);
  }
}

/// Riverpod provider for DeleteNotificationUseCase
final deleteNotificationUseCaseProvider = Provider<DeleteNotificationUseCase>(
  (ref) => throw UnimplementedError('Provider not initialized'),
);

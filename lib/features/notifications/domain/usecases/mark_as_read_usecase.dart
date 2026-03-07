import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/notifications/domain/repositories/notification_repository.dart';

/// Use case for marking a notification as read
class MarkAsReadUseCase {
  final NotificationRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}

/// Riverpod provider for MarkAsReadUseCase
final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>(
  (ref) => throw UnimplementedError('Provider not initialized'),
);

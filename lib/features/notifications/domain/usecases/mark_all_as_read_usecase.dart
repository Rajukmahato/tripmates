import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/notifications/domain/repositories/notification_repository.dart';

/// Use case for marking all notifications as read
class MarkAllAsReadUseCase {
  final NotificationRepository repository;

  MarkAllAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.markAllAsRead();
  }
}

/// Riverpod provider for MarkAllAsReadUseCase
final markAllAsReadUseCaseProvider = Provider<MarkAllAsReadUseCase>(
  (ref) => throw UnimplementedError('Provider not initialized'),
);

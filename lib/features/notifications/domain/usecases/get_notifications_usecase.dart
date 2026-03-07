import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/notifications/domain/entities/notification_entity.dart';
import 'package:tripmates/features/notifications/domain/repositories/notification_repository.dart';

/// Use case for getting notifications
class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    return await repository.getNotifications(
      page: page,
      limit: limit,
      type: type,
    );
  }
}

/// Riverpod provider for GetNotificationsUseCase
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>(
  (ref) => throw UnimplementedError('Provider not initialized'),
);

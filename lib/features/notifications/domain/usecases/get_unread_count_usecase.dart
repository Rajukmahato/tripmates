import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/notifications/domain/repositories/notification_repository.dart';

/// Use case for getting unread notification count
class GetUnreadCountUseCase {
  final NotificationRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getUnreadCount();
  }
}

/// Riverpod provider for GetUnreadCountUseCase
final getUnreadCountUseCaseProvider = Provider<GetUnreadCountUseCase>(
  (ref) => throw UnimplementedError('Provider not initialized'),
);

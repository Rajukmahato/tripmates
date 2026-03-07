import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/partner_requests/data/repositories/partner_request_repository_impl.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';
import 'package:tripmates/features/partner_requests/domain/repositories/partner_request_repository.dart';

/// Use case for sending a partner request
class SendRequestUseCase {
  final PartnerRequestRepository repository;

  SendRequestUseCase(this.repository);

  Future<Either<Failure, PartnerRequestEntity>> call({
    required String receiverId,
    required String tripId,
    String? message,
  }) async {
    return await repository.sendRequest(
      receiverId: receiverId,
      tripId: tripId,
      message: message,
    );
  }
}

/// Riverpod provider
final sendRequestUseCaseProvider = Provider<SendRequestUseCase>((ref) {
  final repository = ref.watch(partnerRequestRepositoryProvider);
  return SendRequestUseCase(repository);
});

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/partner_requests/data/repositories/partner_request_repository_impl.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';
import 'package:tripmates/features/partner_requests/domain/repositories/partner_request_repository.dart';

/// Use case for rejecting a partner request
class RejectRequestUseCase {
  final PartnerRequestRepository repository;

  RejectRequestUseCase(this.repository);

  Future<Either<Failure, PartnerRequestEntity>> call(String requestId) async {
    return await repository.rejectRequest(requestId);
  }
}

/// Riverpod provider
final rejectRequestUseCaseProvider = Provider<RejectRequestUseCase>((ref) {
  final repository = ref.watch(partnerRequestRepositoryProvider);
  return RejectRequestUseCase(repository);
});

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/partner_requests/data/repositories/partner_request_repository_impl.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';
import 'package:tripmates/features/partner_requests/domain/repositories/partner_request_repository.dart';

/// Use case for accepting a partner request
class AcceptRequestUseCase {
  final PartnerRequestRepository repository;

  AcceptRequestUseCase(this.repository);

  Future<Either<Failure, PartnerRequestEntity>> call(String requestId) async {
    return await repository.acceptRequest(requestId);
  }
}

/// Riverpod provider
final acceptRequestUseCaseProvider = Provider<AcceptRequestUseCase>((ref) {
  final repository = ref.watch(partnerRequestRepositoryProvider);
  return AcceptRequestUseCase(repository);
});

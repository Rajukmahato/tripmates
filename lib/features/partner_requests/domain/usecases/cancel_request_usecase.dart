import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/partner_requests/data/repositories/partner_request_repository_impl.dart';
import 'package:tripmates/features/partner_requests/domain/repositories/partner_request_repository.dart';

/// Use case for canceling a partner request
class CancelRequestUseCase {
  final PartnerRequestRepository repository;

  CancelRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.cancelRequest(requestId);
  }
}

/// Riverpod provider
final cancelRequestUseCaseProvider = Provider<CancelRequestUseCase>((ref) {
  final repository = ref.watch(partnerRequestRepositoryProvider);
  return CancelRequestUseCase(repository);
});

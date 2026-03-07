import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/partner_requests/data/repositories/partner_request_repository_impl.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';
import 'package:tripmates/features/partner_requests/domain/repositories/partner_request_repository.dart';

/// Use case for getting partner requests
class GetRequestsUseCase {
  final PartnerRequestRepository repository;

  GetRequestsUseCase(this.repository);

  Future<Either<Failure, List<PartnerRequestEntity>>> call({
    String? filter,
    String? status,
  }) async {
    return await repository.getRequests(filter: filter, status: status);
  }

  Future<Either<Failure, List<PartnerRequestEntity>>> getByTrip(
    String tripId,
  ) async {
    return await repository.getRequestsByTrip(tripId);
  }

  Future<Either<Failure, int>> getPendingCount() async {
    return await repository.getPendingCount();
  }
}

/// Riverpod provider
final getRequestsUseCaseProvider = Provider<GetRequestsUseCase>((ref) {
  final repository = ref.watch(partnerRequestRepositoryProvider);
  return GetRequestsUseCase(repository);
});

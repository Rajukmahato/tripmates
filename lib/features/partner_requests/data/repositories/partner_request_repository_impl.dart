import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/partner_requests/data/datasources/partner_request_remote_datasource.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';
import 'package:tripmates/features/partner_requests/domain/repositories/partner_request_repository.dart';

/// Implementation of PartnerRequestRepository
class PartnerRequestRepositoryImpl implements PartnerRequestRepository {
  final PartnerRequestRemoteDataSource remoteDataSource;

  PartnerRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PartnerRequestEntity>> sendRequest({
    required String receiverId,
    required String tripId,
    String? message,
  }) async {
    try {
      final request = await remoteDataSource.sendRequest(
        receiverId: receiverId,
        tripId: tripId,
        message: message,
      );
      return Right(request);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to send request'));
    }
  }

  @override
  Future<Either<Failure, List<PartnerRequestEntity>>> getRequests({
    String? filter,
    String? status,
  }) async {
    try {
      final requests = await remoteDataSource.getRequests(
        filter: filter,
        status: status,
      );
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get requests'));
    }
  }

  @override
  Future<Either<Failure, List<PartnerRequestEntity>>> getRequestsByTrip(
    String tripId,
  ) async {
    try {
      final requests = await remoteDataSource.getRequests();
      final filtered = requests.where((req) => req.tripId == tripId).toList();
      return Right(filtered);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get requests for trip'));
    }
  }

  @override
  Future<Either<Failure, PartnerRequestEntity>> acceptRequest(
    String requestId,
  ) async {
    try {
      final request = await remoteDataSource.acceptRequest(requestId);
      return Right(request);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to accept request'));
    }
  }

  @override
  Future<Either<Failure, PartnerRequestEntity>> rejectRequest(
    String requestId,
  ) async {
    try {
      final request = await remoteDataSource.rejectRequest(requestId);
      return Right(request);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to reject request'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRequest(String requestId) async {
    try {
      await remoteDataSource.cancelRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to cancel request'));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      final count = await remoteDataSource.getPendingCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get pending count'));
    }
  }
}

/// Riverpod provider
final partnerRequestRepositoryProvider = Provider<PartnerRequestRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(partnerRequestRemoteDataSourceProvider);
  return PartnerRequestRepositoryImpl(remoteDataSource: remoteDataSource);
});

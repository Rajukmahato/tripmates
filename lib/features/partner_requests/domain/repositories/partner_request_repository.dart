import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';

/// Abstract repository for partner request operations
abstract class PartnerRequestRepository {
  /// Send a partner request
  Future<Either<Failure, PartnerRequestEntity>> sendRequest({
    required String receiverId,
    required String tripId,
    String? message,
  });

  /// Get all partner requests (sent and received)
  Future<Either<Failure, List<PartnerRequestEntity>>> getRequests({
    String? filter, // 'sent', 'received', 'all'
    String? status, // 'pending', 'accepted', 'rejected'
  });

  /// Get partner requests for a specific trip
  Future<Either<Failure, List<PartnerRequestEntity>>> getRequestsByTrip(
    String tripId,
  );

  /// Accept a partner request
  Future<Either<Failure, PartnerRequestEntity>> acceptRequest(String requestId);

  /// Reject a partner request
  Future<Either<Failure, PartnerRequestEntity>> rejectRequest(String requestId);

  /// Cancel a sent request
  Future<Either<Failure, void>> cancelRequest(String requestId);

  /// Get pending requests count
  Future<Either<Failure, int>> getPendingCount();
}

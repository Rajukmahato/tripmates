import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';

/// Repository interface for global destinations
abstract interface class IGlobalDestinationRepository {
  /// Get all destinations (optionally include inactive)
  Future<Either<Failure, List<GlobalDestinationEntity>>> getAllDestinations({
    bool includeInactive = false,
  });

  /// Search destinations by name or country
  Future<Either<Failure, List<GlobalDestinationEntity>>> searchDestinations({
    required String query,
    bool includeInactive = false,
  });

  /// Get destination by ID
  Future<Either<Failure, GlobalDestinationEntity>> getDestinationById(
    String id,
  );

  /// [Admin] Create new destination
  Future<Either<Failure, GlobalDestinationEntity>> createDestination(
    Map<String, dynamic> data,
  );

  /// [Admin] Update destination
  Future<Either<Failure, GlobalDestinationEntity>> updateDestination(
    String id,
    Map<String, dynamic> data,
  );

  /// [Admin] Delete destination
  Future<Either<Failure, void>> deleteDestination(String id);

  /// [Admin] Toggle destination active status
  Future<Either<Failure, GlobalDestinationEntity>> toggleDestinationStatus(
    String id,
  );

  /// [Admin] Get destination statistics
  Future<Either<Failure, Map<String, dynamic>>> getDestinationStats();
}

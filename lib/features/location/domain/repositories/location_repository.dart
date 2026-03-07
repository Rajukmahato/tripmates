import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/location/domain/entities/location_entity.dart';

abstract interface class ILocationRepository {
  Future<Either<Failure, void>> startLocationSharing({
    required String tripId,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, void>> updateLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, void>> stopLocationSharing(String tripId);

  Future<Either<Failure, List<LocationEntity>>> getTripLocations(String tripId);

  Future<Either<Failure, List<Map<String, dynamic>>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
  });

  Future<Either<Failure, Map<String, dynamic>>> getRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  });
}

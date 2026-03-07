import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/location/data/datasources/location_remote_datasource.dart';
import 'package:tripmates/features/location/domain/entities/location_entity.dart';
import 'package:tripmates/features/location/domain/repositories/location_repository.dart';

/// Provider for location repository implementation
final locationRepositoryProvider = Provider<ILocationRepository>((ref) {
  final remoteDataSource = ref.read(locationRemoteDataSourceProvider);
  return LocationRepository(remoteDataSource: remoteDataSource);
});

/// Location repository implementation
class LocationRepository implements ILocationRepository {
  final ILocationRemoteDataSource _remoteDataSource;

  LocationRepository({required ILocationRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, void>> startLocationSharing({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _remoteDataSource.startLocationSharing(
        tripId: tripId,
        latitude: latitude,
        longitude: longitude,
      );
      log('Started location sharing for trip $tripId');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _remoteDataSource.updateLocation(
        tripId: tripId,
        latitude: latitude,
        longitude: longitude,
      );
      log('Updated location for trip $tripId: $latitude, $longitude');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stopLocationSharing(String tripId) async {
    try {
      await _remoteDataSource.stopLocationSharing(tripId);
      log('Stopped location sharing for trip $tripId');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getTripLocations(
    String tripId,
  ) async {
    try {
      final apiModels = await _remoteDataSource.getTripLocations(tripId);
      final entities = apiModels.map((model) => model.toEntity()).toList();
      log('Fetched ${entities.length} locations for trip $tripId');
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
  }) async {
    try {
      final places = await _remoteDataSource.getNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        type: type,
      );
      log('Fetched ${places.length} nearby places of type $type');
      return Right(places);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    try {
      final route = await _remoteDataSource.getRoute(
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
      );
      log(
        'Fetched route from ($startLatitude, $startLongitude) to ($endLatitude, $endLongitude)',
      );
      return Right(route);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

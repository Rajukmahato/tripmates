import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/trip/data/datasources/local/trip_local_datasource.dart';
import 'package:tripmates/features/trip/data/datasources/trip_datasource.dart';
import 'package:tripmates/features/trip/data/models/trip_hive_model.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

final tripRepositoryProvider = Provider<ITripRepository>((ref) {
  final tripLocalDatasource = ref.read(tripLocalDatasourceProvider);
  return TripRepository(tripLocalDatasource: tripLocalDatasource);
});

class TripRepository implements ITripRepository {
  final ITripDataSource _tripLocalDataSource;

  TripRepository({required ITripDataSource tripLocalDatasource})
    : _tripLocalDataSource = tripLocalDatasource;

  @override
  Future<Either<Failure, bool>> createTrip(TripEntity trip) async {
    try {
      final tripModel = TripHiveModel.fromEntity(trip);
      final result = await _tripLocalDataSource.createTrip(tripModel);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to create trip"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTrip(String tripId) async {
    try {
      final result = await _tripLocalDataSource.deleteTrip(tripId);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to delete trip"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getAllTrips() async {
    try {
      final models = await _tripLocalDataSource.getAllTrips();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> getTripById(String tripId) async {
    try {
      final model = await _tripLocalDataSource.getTripById(tripId);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: 'Trip not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateTrip(TripEntity trip) async {
    try {
      final tripModel = TripHiveModel.fromEntity(trip);
      final result = await _tripLocalDataSource.updateTrip(tripModel);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to update trip"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getTripsByUser(
    String userId,
  ) async {
    try {
      final models = await _tripLocalDataSource.getMyTrips(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getPlannedTrips() async {
    try {
      final models = await _tripLocalDataSource.getAllTrips();
      final entities = models
          .where((model) => model.status == 'planned')
          .map((model) => model.toEntity())
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getCompletedTrips() async {
    try {
      final models = await _tripLocalDataSource.getAllTrips();
      final entities = models
          .where((model) => model.status == 'completed')
          .map((model) => model.toEntity())
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getTripsByCategory(
    String categoryId,
  ) async {
    try {
      final models = await _tripLocalDataSource.getAllTrips();
      final entities = models
          .where((model) => model.category == categoryId)
          .map((model) => model.toEntity())
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(photo) async {
    // TODO: Implement photo upload to server/storage
    return Right(photo.path);
  }

  @override
  Future<Either<Failure, String>> uploadVideo(video) async {
    // TODO: Implement video upload to server/storage
    return Right(video.path);
  }
}

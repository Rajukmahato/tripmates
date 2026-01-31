import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';

abstract interface class ITripRepository {
  Future<Either<Failure, List<TripEntity>>> getAllTrips();
  Future<Either<Failure, List<TripEntity>>> getTripsByUser(String userId);
  Future<Either<Failure, List<TripEntity>>> getPlannedTrips();
  Future<Either<Failure, List<TripEntity>>> getCompletedTrips();
  Future<Either<Failure, List<TripEntity>>> getTripsByCategory(
    String categoryId,
  );
  Future<Either<Failure, TripEntity>> getTripById(String tripId);
  Future<Either<Failure, bool>> createTrip(TripEntity trip);
  Future<Either<Failure, bool>> updateTrip(TripEntity trip);
  Future<Either<Failure, bool>> deleteTrip(String tripId);
  Future<Either<Failure, String>> uploadPhoto(File photo);
  Future<Either<Failure, String>> uploadVideo(File video);
}

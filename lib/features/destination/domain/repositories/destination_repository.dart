import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/destination/domain/entities/destination_entity.dart';

abstract interface class IDestinationRepository {
  Future<Either<Failure, List<DestinationEntity>>> getAllDestinations();
  Future<Either<Failure, List<DestinationEntity>>> getDestinationsByTrip(
    String tripId,
  );
  Future<Either<Failure, List<DestinationEntity>>> getDestinationsByUser(
    String userId,
  );
  Future<Either<Failure, List<DestinationEntity>>> getDestinationsByCategory(
    String categoryId,
  );
  Future<Either<Failure, List<DestinationEntity>>> getVisitedDestinations();
  Future<Either<Failure, List<DestinationEntity>>> getUnvisitedDestinations();
  Future<Either<Failure, DestinationEntity>> getDestinationById(
    String destinationId,
  );
  Future<Either<Failure, bool>> createDestination(
    DestinationEntity destination,
  );
  Future<Either<Failure, bool>> updateDestination(
    DestinationEntity destination,
  );
  Future<Either<Failure, bool>> deleteDestination(String destinationId);
  Future<Either<Failure, String>> uploadPhoto(File photo);
  Future<Either<Failure, String>> uploadVideo(File video);
}

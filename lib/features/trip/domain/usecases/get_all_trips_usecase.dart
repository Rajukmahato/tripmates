import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

final getAllTripsUsecaseProvider = Provider<GetAllTripsUsecase>((ref) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return GetAllTripsUsecase(tripRepository: tripRepository);
});

class GetAllTripsUsecase implements UsecaseWithoutParms<List<TripEntity>> {
  final ITripRepository _tripRepository;

  GetAllTripsUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, List<TripEntity>>> call() {
    return _tripRepository.getAllTrips();
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

class GetJoinedTripsParams extends Equatable {
  final String userId;

  const GetJoinedTripsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getJoinedTripsUsecaseProvider = Provider<GetJoinedTripsUsecase>((ref) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return GetJoinedTripsUsecase(tripRepository: tripRepository);
});

class GetJoinedTripsUsecase
    implements UsecaseWithParms<List<TripEntity>, GetJoinedTripsParams> {
  final ITripRepository _tripRepository;

  GetJoinedTripsUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, List<TripEntity>>> call(GetJoinedTripsParams params) {
    return _tripRepository.getJoinedTrips(params.userId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

class GetMyTripsParams extends Equatable {
  final String userId;

  const GetMyTripsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getMyTripsUsecaseProvider = Provider<GetMyTripsUsecase>((ref) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return GetMyTripsUsecase(tripRepository: tripRepository);
});

class GetMyTripsUsecase
    implements UsecaseWithParms<List<TripEntity>, GetMyTripsParams> {
  final ITripRepository _tripRepository;

  GetMyTripsUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, List<TripEntity>>> call(GetMyTripsParams params) {
    return _tripRepository.getTripsByUser(params.userId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

class DeleteTripParams extends Equatable {
  final String tripId;

  const DeleteTripParams({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

final deleteTripUsecaseProvider = Provider<DeleteTripUsecase>((ref) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return DeleteTripUsecase(tripRepository: tripRepository);
});

class DeleteTripUsecase implements UsecaseWithParms<bool, DeleteTripParams> {
  final ITripRepository _tripRepository;

  DeleteTripUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteTripParams params) {
    return _tripRepository.deleteTrip(params.tripId);
  }
}

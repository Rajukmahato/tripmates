import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

final updateTripItineraryUsecaseProvider = Provider<UpdateTripItineraryUsecase>(
  (ref) {
    final tripRepository = ref.read(tripRepositoryProvider);
    return UpdateTripItineraryUsecase(tripRepository: tripRepository);
  },
);

class UpdateTripItineraryUsecase
    implements UsecaseWithParms<bool, UpdateItineraryParams> {
  final ITripRepository _tripRepository;

  UpdateTripItineraryUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateItineraryParams params) {
    return _tripRepository.updateItinerary(
      tripId: params.tripId,
      itinerary: params.itinerary,
    );
  }
}

class UpdateItineraryParams extends Equatable {
  final String tripId;
  final List<Map<String, dynamic>> itinerary;

  const UpdateItineraryParams({required this.tripId, required this.itinerary});

  @override
  List<Object?> get props => [tripId, itinerary];
}

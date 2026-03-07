import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/entities/itinerary_item_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

final getTripItineraryUsecaseProvider = Provider<GetTripItineraryUsecase>((
  ref,
) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return GetTripItineraryUsecase(tripRepository: tripRepository);
});

class GetTripItineraryUsecase
    implements UsecaseWithParms<List<ItineraryItemEntity>, GetItineraryParams> {
  final ITripRepository _tripRepository;

  GetTripItineraryUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, List<ItineraryItemEntity>>> call(
    GetItineraryParams params,
  ) {
    return _tripRepository.getItinerary(params.tripId);
  }
}

class GetItineraryParams extends Equatable {
  final String tripId;

  const GetItineraryParams({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

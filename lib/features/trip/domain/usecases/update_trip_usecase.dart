import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

class UpdateTripParams extends Equatable {
  final String tripId;
  final String tripName;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final TripStatus status;
  final String? description;
  final String? category;
  final String? media;
  final List<String>? destinationIds;

  const UpdateTripParams({
    required this.tripId,
    required this.tripName,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.description,
    this.category,
    this.media,
    this.destinationIds,
  });

  @override
  List<Object?> get props => [
    tripId,
    tripName,
    destination,
    startDate,
    endDate,
    status,
    description,
    category,
    media,
    destinationIds,
  ];
}

final updateTripUsecaseProvider = Provider<UpdateTripUsecase>((ref) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return UpdateTripUsecase(tripRepository: tripRepository);
});

class UpdateTripUsecase implements UsecaseWithParms<bool, UpdateTripParams> {
  final ITripRepository _tripRepository;

  UpdateTripUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateTripParams params) {
    final tripEntity = TripEntity(
      tripId: params.tripId,
      tripName: params.tripName,
      destination: params.destination,
      startDate: params.startDate,
      endDate: params.endDate,
      status: params.status,
      description: params.description,
      category: params.category,
      media: params.media,
      destinationIds: params.destinationIds,
    );

    return _tripRepository.updateTrip(tripEntity);
  }
}

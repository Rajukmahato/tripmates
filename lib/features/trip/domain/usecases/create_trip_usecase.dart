import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

class CreateTripParams extends Equatable {
  final String tripName;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final TripStatus status;
  final String? description;
  final String? category;
  final String? media;
  final List<String>? destinationIds;
  final String userId;

  const CreateTripParams({
    required this.tripName,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.description,
    this.category,
    this.media,
    this.destinationIds,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    tripName,
    destination,
    startDate,
    endDate,
    status,
    description,
    category,
    media,
    destinationIds,
    userId,
  ];
}

final createTripUsecaseProvider = Provider<CreateTripUsecase>((ref) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return CreateTripUsecase(tripRepository: tripRepository);
});

class CreateTripUsecase implements UsecaseWithParms<bool, CreateTripParams> {
  final ITripRepository _tripRepository;

  CreateTripUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, bool>> call(CreateTripParams params) {
    final tripEntity = TripEntity(
      tripName: params.tripName,
      destination: params.destination,
      startDate: params.startDate,
      endDate: params.endDate,
      status: params.status,
      description: params.description,
      category: params.category,
      media: params.media,
      destinationIds: params.destinationIds,
      createdBy: params.userId,
      createdAt: DateTime.now(),
    );

    return _tripRepository.createTrip(tripEntity);
  }
}

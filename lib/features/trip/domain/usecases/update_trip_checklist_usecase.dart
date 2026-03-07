import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';

class UpdateTripChecklistUsecase
    implements UsecaseWithParms<bool, UpdateChecklistParams> {
  final ITripRepository _tripRepository;

  UpdateTripChecklistUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateChecklistParams params) {
    return _tripRepository.updateChecklist(
      tripId: params.tripId,
      checklist: params.checklist,
    );
  }
}

class UpdateChecklistParams extends Equatable {
  final String tripId;
  final List<Map<String, dynamic>> checklist;

  const UpdateChecklistParams({required this.tripId, required this.checklist});

  @override
  List<Object?> get props => [tripId, checklist];
}

final updateTripChecklistUsecaseProvider = Provider<UpdateTripChecklistUsecase>(
  (ref) {
    final tripRepository = ref.read(tripRepositoryProvider);
    return UpdateTripChecklistUsecase(tripRepository: tripRepository);
  },
);

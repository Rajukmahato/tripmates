import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/domain/entities/checklist_item_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';

class GetTripChecklistUsecase
    implements UsecaseWithParms<List<ChecklistItemEntity>, GetChecklistParams> {
  final ITripRepository _tripRepository;

  GetTripChecklistUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, List<ChecklistItemEntity>>> call(
    GetChecklistParams params,
  ) {
    return _tripRepository.getChecklist(params.tripId);
  }
}

class GetChecklistParams extends Equatable {
  final String tripId;

  const GetChecklistParams({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

final getTripChecklistUsecaseProvider = Provider<GetTripChecklistUsecase>((
  ref,
) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return GetTripChecklistUsecase(tripRepository: tripRepository);
});

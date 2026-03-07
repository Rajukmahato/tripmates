import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

class SendJoinRequestParams extends Equatable {
  final String tripId;
  final String userId;
  final String? message;

  const SendJoinRequestParams({
    required this.tripId,
    required this.userId,
    this.message,
  });

  @override
  List<Object?> get props => [tripId, userId, message];
}

final sendJoinRequestUsecaseProvider = Provider<SendJoinRequestUsecase>((ref) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return SendJoinRequestUsecase(tripRepository: tripRepository);
});

class SendJoinRequestUsecase
    implements UsecaseWithParms<bool, SendJoinRequestParams> {
  final ITripRepository _tripRepository;

  SendJoinRequestUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, bool>> call(SendJoinRequestParams params) {
    return _tripRepository.sendJoinRequest(
      tripId: params.tripId,
      userId: params.userId,
      message: params.message,
    );
  }
}

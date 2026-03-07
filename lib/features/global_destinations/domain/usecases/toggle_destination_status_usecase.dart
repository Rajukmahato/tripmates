import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/global_destinations/data/repositories/global_destination_repository_impl.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Parameters for toggle destination status use case
class ToggleDestinationStatusParams extends Equatable {
  final String id;

  const ToggleDestinationStatusParams({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Provider for ToggleDestinationStatusUseCase
final toggleDestinationStatusUseCaseProvider =
    Provider<ToggleDestinationStatusUseCase>((ref) {
      final repository = ref.read(globalDestinationRepositoryProvider);
      return ToggleDestinationStatusUseCase(repository: repository);
    });

/// Use case for toggling destination active status (Admin only)
class ToggleDestinationStatusUseCase
    implements
        UsecaseWithParms<
          GlobalDestinationEntity,
          ToggleDestinationStatusParams
        > {
  final IGlobalDestinationRepository _repository;

  ToggleDestinationStatusUseCase({
    required IGlobalDestinationRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, GlobalDestinationEntity>> call(
    ToggleDestinationStatusParams params,
  ) async {
    return await _repository.toggleDestinationStatus(params.id);
  }
}

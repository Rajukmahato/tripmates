import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/global_destinations/data/repositories/global_destination_repository_impl.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Parameters for update destination use case
class UpdateDestinationParams extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const UpdateDestinationParams({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

/// Provider for UpdateDestinationUseCase
final updateDestinationUseCaseProvider = Provider<UpdateDestinationUseCase>((
  ref,
) {
  final repository = ref.read(globalDestinationRepositoryProvider);
  return UpdateDestinationUseCase(repository: repository);
});

/// Use case for updating a destination (Admin only)
class UpdateDestinationUseCase
    implements
        UsecaseWithParms<GlobalDestinationEntity, UpdateDestinationParams> {
  final IGlobalDestinationRepository _repository;

  UpdateDestinationUseCase({required IGlobalDestinationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, GlobalDestinationEntity>> call(
    UpdateDestinationParams params,
  ) async {
    return await _repository.updateDestination(params.id, params.data);
  }
}

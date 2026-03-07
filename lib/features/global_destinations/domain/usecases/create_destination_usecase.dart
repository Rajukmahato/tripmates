import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/global_destinations/data/repositories/global_destination_repository_impl.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Parameters for create destination use case
class CreateDestinationParams extends Equatable {
  final Map<String, dynamic> data;

  const CreateDestinationParams({required this.data});

  @override
  List<Object?> get props => [data];
}

/// Provider for CreateDestinationUseCase
final createDestinationUseCaseProvider = Provider<CreateDestinationUseCase>((
  ref,
) {
  final repository = ref.read(globalDestinationRepositoryProvider);
  return CreateDestinationUseCase(repository: repository);
});

/// Use case for creating a new destination (Admin only)
class CreateDestinationUseCase
    implements
        UsecaseWithParms<GlobalDestinationEntity, CreateDestinationParams> {
  final IGlobalDestinationRepository _repository;

  CreateDestinationUseCase({required IGlobalDestinationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, GlobalDestinationEntity>> call(
    CreateDestinationParams params,
  ) async {
    return await _repository.createDestination(params.data);
  }
}

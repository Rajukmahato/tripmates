import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/global_destinations/data/repositories/global_destination_repository_impl.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Parameters for delete destination use case
class DeleteDestinationParams extends Equatable {
  final String id;

  const DeleteDestinationParams({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Provider for DeleteDestinationUseCase
final deleteDestinationUseCaseProvider = Provider<DeleteDestinationUseCase>((
  ref,
) {
  final repository = ref.read(globalDestinationRepositoryProvider);
  return DeleteDestinationUseCase(repository: repository);
});

/// Use case for deleting a destination (Admin only)
class DeleteDestinationUseCase
    implements UsecaseWithParms<void, DeleteDestinationParams> {
  final IGlobalDestinationRepository _repository;

  DeleteDestinationUseCase({required IGlobalDestinationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, void>> call(DeleteDestinationParams params) async {
    return await _repository.deleteDestination(params.id);
  }
}

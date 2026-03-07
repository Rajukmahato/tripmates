import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/global_destinations/data/repositories/global_destination_repository_impl.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Parameters for get destination by ID use case
class GetDestinationByIdParams extends Equatable {
  final String id;

  const GetDestinationByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Provider for GetDestinationByIdUseCase
final getDestinationByIdUseCaseProvider = Provider<GetDestinationByIdUseCase>((
  ref,
) {
  final repository = ref.read(globalDestinationRepositoryProvider);
  return GetDestinationByIdUseCase(repository: repository);
});

/// Use case for fetching a destination by ID
class GetDestinationByIdUseCase
    implements
        UsecaseWithParms<GlobalDestinationEntity, GetDestinationByIdParams> {
  final IGlobalDestinationRepository _repository;

  GetDestinationByIdUseCase({required IGlobalDestinationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, GlobalDestinationEntity>> call(
    GetDestinationByIdParams params,
  ) async {
    return await _repository.getDestinationById(params.id);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/global_destinations/data/repositories/global_destination_repository_impl.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Parameters for get all destinations use case
class GetAllDestinationsParams extends Equatable {
  final bool includeInactive;

  const GetAllDestinationsParams({this.includeInactive = false});

  @override
  List<Object?> get props => [includeInactive];
}

/// Provider for GetAllDestinationsUseCase
final getAllDestinationsUseCaseProvider = Provider<GetAllDestinationsUseCase>((
  ref,
) {
  final repository = ref.read(globalDestinationRepositoryProvider);
  return GetAllDestinationsUseCase(repository: repository);
});

/// Use case for fetching all global destinations
class GetAllDestinationsUseCase
    implements
        UsecaseWithParms<
          List<GlobalDestinationEntity>,
          GetAllDestinationsParams
        > {
  final IGlobalDestinationRepository _repository;

  GetAllDestinationsUseCase({required IGlobalDestinationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<GlobalDestinationEntity>>> call(
    GetAllDestinationsParams params,
  ) async {
    return await _repository.getAllDestinations(
      includeInactive: params.includeInactive,
    );
  }
}

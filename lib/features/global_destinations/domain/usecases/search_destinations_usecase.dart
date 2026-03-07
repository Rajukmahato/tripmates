import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/global_destinations/data/repositories/global_destination_repository_impl.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Parameters for search destinations use case
class SearchDestinationsParams extends Equatable {
  final String query;
  final bool includeInactive;

  const SearchDestinationsParams({
    required this.query,
    this.includeInactive = false,
  });

  @override
  List<Object?> get props => [query, includeInactive];
}

/// Provider for SearchDestinationsUseCase
final searchDestinationsUseCaseProvider = Provider<SearchDestinationsUseCase>((
  ref,
) {
  final repository = ref.read(globalDestinationRepositoryProvider);
  return SearchDestinationsUseCase(repository: repository);
});

/// Use case for searching global destinations
class SearchDestinationsUseCase
    implements
        UsecaseWithParms<
          List<GlobalDestinationEntity>,
          SearchDestinationsParams
        > {
  final IGlobalDestinationRepository _repository;

  SearchDestinationsUseCase({required IGlobalDestinationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<GlobalDestinationEntity>>> call(
    SearchDestinationsParams params,
  ) async {
    return await _repository.searchDestinations(
      query: params.query,
      includeInactive: params.includeInactive,
    );
  }
}

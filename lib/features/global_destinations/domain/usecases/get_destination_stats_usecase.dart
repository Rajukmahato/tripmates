import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/global_destinations/data/repositories/global_destination_repository_impl.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Provider for GetDestinationStatsUseCase
final getDestinationStatsUseCaseProvider = Provider<GetDestinationStatsUseCase>(
  (ref) {
    final repository = ref.read(globalDestinationRepositoryProvider);
    return GetDestinationStatsUseCase(repository: repository);
  },
);

/// Use case for fetching destination statistics (Admin only)
class GetDestinationStatsUseCase
    implements UsecaseWithoutParms<Map<String, dynamic>> {
  final IGlobalDestinationRepository _repository;

  GetDestinationStatsUseCase({required IGlobalDestinationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await _repository.getDestinationStats();
  }
}

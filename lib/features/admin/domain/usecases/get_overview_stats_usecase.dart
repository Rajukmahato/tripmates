import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:tripmates/features/admin/domain/repositories/admin_repository.dart';

/// Use case to get admin overview statistics
class GetOverviewStatsUseCase implements UsecaseWithoutParms<AdminStatsEntity> {
  final AdminRepository _repository;

  GetOverviewStatsUseCase(this._repository);

  @override
  Future<Either<Failure, AdminStatsEntity>> call() {
    return _repository.getOverviewStats();
  }
}

/// Provider
final getOverviewStatsUseCaseProvider = Provider<GetOverviewStatsUseCase>((
  ref,
) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetOverviewStatsUseCase(repository);
});

/// Temporary provider (will be implemented in data layer)
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  throw UnimplementedError('AdminRepository not yet implemented');
});

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/admin/domain/entities/admin_trip_entity.dart';
import 'package:tripmates/features/admin/domain/repositories/admin_repository.dart';
import 'package:tripmates/features/admin/domain/usecases/get_overview_stats_usecase.dart';

/// Use case to get all trips for admin
class GetAllAdminTripsUseCase
    implements UsecaseWithoutParms<List<AdminTripEntity>> {
  final AdminRepository repository;

  GetAllAdminTripsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AdminTripEntity>>> call() {
    return repository.getAllTrips();
  }
}

/// Provider
final getAllAdminTripsUseCaseProvider = Provider<GetAllAdminTripsUseCase>((
  ref,
) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetAllAdminTripsUseCase(repository);
});

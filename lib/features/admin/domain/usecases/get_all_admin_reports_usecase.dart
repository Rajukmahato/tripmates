import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/admin/domain/entities/admin_report_entity.dart';
import 'package:tripmates/features/admin/domain/repositories/admin_repository.dart';
import 'package:tripmates/features/admin/domain/usecases/get_overview_stats_usecase.dart';

/// Use case to get all reports for admin
class GetAllAdminReportsUseCase
    implements UsecaseWithoutParms<List<AdminReportEntity>> {
  final AdminRepository repository;

  GetAllAdminReportsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AdminReportEntity>>> call() {
    return repository.getAllReports();
  }
}

/// Provider
final getAllAdminReportsUseCaseProvider = Provider<GetAllAdminReportsUseCase>((
  ref,
) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetAllAdminReportsUseCase(repository);
});

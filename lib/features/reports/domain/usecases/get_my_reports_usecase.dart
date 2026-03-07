import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reports/data/repositories/report_repository_impl.dart';
import 'package:tripmates/features/reports/domain/entities/report_entity.dart';
import 'package:tripmates/features/reports/domain/repositories/report_repository.dart';

/// Use case for getting user's reports
class GetMyReportsUseCase {
  final ReportRepository repository;

  GetMyReportsUseCase(this.repository);

  Future<Either<Failure, List<ReportEntity>>> call() async {
    return await repository.getMyReports();
  }
}

/// Riverpod provider
final getMyReportsUseCaseProvider = Provider<GetMyReportsUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GetMyReportsUseCase(repository);
});

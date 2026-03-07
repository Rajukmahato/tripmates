import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reports/data/repositories/report_repository_impl.dart';
import 'package:tripmates/features/reports/domain/entities/report_entity.dart';
import 'package:tripmates/features/reports/domain/repositories/report_repository.dart';

/// Use case for submitting a report
class SubmitReportUseCase {
  final ReportRepository repository;

  SubmitReportUseCase(this.repository);

  Future<Either<Failure, ReportEntity>> call({
    required String reportedEntityType,
    required String reportedEntityId,
    required ReportReason reason,
    String? description,
  }) async {
    return await repository.submitReport(
      reportedEntityType: reportedEntityType,
      reportedEntityId: reportedEntityId,
      reason: reason,
      description: description,
    );
  }
}

/// Riverpod provider
final submitReportUseCaseProvider = Provider<SubmitReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return SubmitReportUseCase(repository);
});

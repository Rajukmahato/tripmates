import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/admin/domain/repositories/admin_repository.dart';
import 'package:tripmates/features/admin/domain/usecases/get_overview_stats_usecase.dart';

/// Use case to review a report
class ReviewReportUseCase
    implements UsecaseWithParms<bool, ReviewReportParams> {
  final AdminRepository repository;

  ReviewReportUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ReviewReportParams params) {
    return repository.reviewReport(
      params.reportId,
      params.status,
      params.notes,
    );
  }
}

/// Parameters
class ReviewReportParams {
  final String reportId;
  final String status; // 'reviewed', 'resolved', 'dismissed'
  final String? notes;

  ReviewReportParams({
    required this.reportId,
    required this.status,
    this.notes,
  });
}

/// Provider
final reviewReportUseCaseProvider = Provider<ReviewReportUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return ReviewReportUseCase(repository);
});

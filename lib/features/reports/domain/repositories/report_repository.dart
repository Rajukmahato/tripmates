import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reports/domain/entities/report_entity.dart';

/// Abstract repository for report operations
abstract class ReportRepository {
  Future<Either<Failure, ReportEntity>> submitReport({
    required String reportedEntityType,
    required String reportedEntityId,
    required ReportReason reason,
    String? description,
  });

  Future<Either<Failure, List<ReportEntity>>> getMyReports();
}

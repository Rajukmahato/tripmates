import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reports/data/datasources/report_remote_datasource.dart';
import 'package:tripmates/features/reports/domain/entities/report_entity.dart';
import 'package:tripmates/features/reports/domain/repositories/report_repository.dart';

/// Implementation of ReportRepository
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReportEntity>> submitReport({
    required String reportedEntityType,
    required String reportedEntityId,
    required ReportReason reason,
    String? description,
  }) async {
    try {
      final report = await remoteDataSource.submitReport(
        reportedEntityType: reportedEntityType,
        reportedEntityId: reportedEntityId,
        reason: reason,
        description: description,
      );
      return Right(report);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to submit report'));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getMyReports() async {
    try {
      final reports = await remoteDataSource.getMyReports();
      return Right(reports);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get reports'));
    }
  }
}

/// Riverpod provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remoteDataSource = ref.watch(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(remoteDataSource: remoteDataSource);
});

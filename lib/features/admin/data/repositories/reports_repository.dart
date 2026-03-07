import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/admin/data/datasources/reports_remote_datasource.dart';
import 'package:tripmates/features/admin/domain/entities/report_entity.dart';
import 'package:tripmates/features/admin/domain/usecases/reports_usecases.dart';

// Riverpod provider for reports repository
final reportsRepositoryProvider = Provider<IReportsRepository>((ref) {
  final datasource = ref.read(reportsRemoteDataSourceProvider);
  return ReportsRepository(datasource: datasource);
});

// Riverpod providers for use cases
final getAllReportsUsecaseProvider = Provider((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return GetAllReportsUsecase(repository);
});

final getReportByIdUsecaseProvider = Provider((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return GetReportByIdUsecase(repository);
});

final getReportsByUserUsecaseProvider = Provider((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return GetReportsByUserUsecase(repository);
});

final reviewReportUsecaseProvider = Provider((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return ReviewReportUsecase(repository);
});

final resolveReportUsecaseProvider = Provider((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return ResolveReportUsecase(repository);
});

final getReportStatsUsecaseProvider = Provider((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return GetReportStatsUsecase(repository);
});

class ReportsRepository implements IReportsRepository {
  final IReportsRemoteDataSource _datasource;

  ReportsRepository({required IReportsRemoteDataSource datasource})
    : _datasource = datasource;

  @override
  Future<Either<Failure, List<ReportEntity>>> getAllReports({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
  }) async {
    try {
      final models = await _datasource.getAllReports(
        page: page,
        limit: limit,
        status: status,
        type: type,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      log('ReportsRepository: getAllReports error - ${e.message}');
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> getReportById(String reportId) async {
    try {
      final model = await _datasource.getReportById(reportId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      log('ReportsRepository: getReportById error - ${e.message}');
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getReportsByUser(
    String userId,
  ) async {
    try {
      final models = await _datasource.getReportsByUser(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      log('ReportsRepository: getReportsByUser error - ${e.message}');
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> reviewReport({
    required String reportId,
    required String status,
    String? notes,
  }) async {
    try {
      final model = await _datasource.reviewReport(
        reportId: reportId,
        status: status,
        notes: notes,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      log('ReportsRepository: reviewReport error - ${e.message}');
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> resolveReport({
    required String reportId,
    required String action,
    String? notes,
  }) async {
    try {
      final model = await _datasource.resolveReport(
        reportId: reportId,
        action: action,
        notes: notes,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      log('ReportsRepository: resolveReport error - ${e.message}');
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportStats() async {
    try {
      final stats = await _datasource.getReportStats();
      return Right(stats);
    } on ServerException catch (e) {
      log('ReportsRepository: getReportStats error - ${e.message}');
      return Left(ApiFailure(message: e.message));
    }
  }
}

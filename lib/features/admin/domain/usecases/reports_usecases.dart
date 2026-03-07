import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/admin/domain/entities/report_entity.dart';

// ============ Repository Interface ============
abstract class IReportsRepository {
  Future<Either<Failure, List<ReportEntity>>> getAllReports({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
  });

  Future<Either<Failure, ReportEntity>> getReportById(String reportId);

  Future<Either<Failure, List<ReportEntity>>> getReportsByUser(String userId);

  Future<Either<Failure, ReportEntity>> reviewReport({
    required String reportId,
    required String status,
    String? notes,
  });

  Future<Either<Failure, ReportEntity>> resolveReport({
    required String reportId,
    required String action,
    String? notes,
  });

  Future<Either<Failure, Map<String, dynamic>>> getReportStats();
}

// ============ Use Case Params ============

class GetAllReportsParams extends Equatable {
  final int page;
  final int limit;
  final String? status;
  final String? type;

  const GetAllReportsParams({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.type,
  });

  @override
  List<Object?> get props => [page, limit, status, type];
}

class GetReportByIdParams extends Equatable {
  final String reportId;

  const GetReportByIdParams({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}

class GetReportsByUserParams extends Equatable {
  final String userId;

  const GetReportsByUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ReviewReportParams extends Equatable {
  final String reportId;
  final String status;
  final String? notes;

  const ReviewReportParams({
    required this.reportId,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [reportId, status, notes];
}

class ResolveReportParams extends Equatable {
  final String reportId;
  final String action;
  final String? notes;

  const ResolveReportParams({
    required this.reportId,
    required this.action,
    this.notes,
  });

  @override
  List<Object?> get props => [reportId, action, notes];
}

// ============ Use Cases ============

class GetAllReportsUsecase
    implements UsecaseWithParms<List<ReportEntity>, GetAllReportsParams> {
  final IReportsRepository repository;

  GetAllReportsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ReportEntity>>> call(
    GetAllReportsParams params,
  ) async {
    return await repository.getAllReports(
      page: params.page,
      limit: params.limit,
      status: params.status,
      type: params.type,
    );
  }
}

class GetReportByIdUsecase
    implements UsecaseWithParms<ReportEntity, GetReportByIdParams> {
  final IReportsRepository repository;

  GetReportByIdUsecase(this.repository);

  @override
  Future<Either<Failure, ReportEntity>> call(GetReportByIdParams params) async {
    return await repository.getReportById(params.reportId);
  }
}

class GetReportsByUserUsecase
    implements UsecaseWithParms<List<ReportEntity>, GetReportsByUserParams> {
  final IReportsRepository repository;

  GetReportsByUserUsecase(this.repository);

  @override
  Future<Either<Failure, List<ReportEntity>>> call(
    GetReportsByUserParams params,
  ) async {
    return await repository.getReportsByUser(params.userId);
  }
}

class ReviewReportUsecase
    implements UsecaseWithParms<ReportEntity, ReviewReportParams> {
  final IReportsRepository repository;

  ReviewReportUsecase(this.repository);

  @override
  Future<Either<Failure, ReportEntity>> call(ReviewReportParams params) async {
    return await repository.reviewReport(
      reportId: params.reportId,
      status: params.status,
      notes: params.notes,
    );
  }
}

class ResolveReportUsecase
    implements UsecaseWithParms<ReportEntity, ResolveReportParams> {
  final IReportsRepository repository;

  ResolveReportUsecase(this.repository);

  @override
  Future<Either<Failure, ReportEntity>> call(ResolveReportParams params) async {
    return await repository.resolveReport(
      reportId: params.reportId,
      action: params.action,
      notes: params.notes,
    );
  }
}

class GetReportStatsUsecase
    implements UsecaseWithoutParms<Map<String, dynamic>> {
  final IReportsRepository repository;

  GetReportStatsUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getReportStats();
  }
}

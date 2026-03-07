import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/admin/data/models/report_api_model.dart';

// Riverpod provider for reports remote datasource
final reportsRemoteDataSourceProvider = Provider<IReportsRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return ReportsRemoteDataSource(apiClient: apiClient);
});

abstract class IReportsRemoteDataSource {
  Future<List<ReportApiModel>> getAllReports({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
  });

  Future<ReportApiModel> getReportById(String reportId);

  Future<List<ReportApiModel>> getReportsByUser(String userId);

  Future<ReportApiModel> reviewReport({
    required String reportId,
    required String status,
    String? notes,
  });

  Future<ReportApiModel> resolveReport({
    required String reportId,
    required String action, // 'warn', 'suspend', 'ban', 'dismiss'
    String? notes,
  });

  Future<Map<String, dynamic>> getReportStats();
}

class ReportsRemoteDataSource implements IReportsRemoteDataSource {
  final ApiClient _apiClient;

  ReportsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ReportApiModel>> getAllReports({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
  }) async {
    try {
      Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final response = await _apiClient.get(
        ApiEndpoints.adminAllReports,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      final reports = (data)
          .map((json) => ReportApiModel.fromJson(json as Map<String, dynamic>))
          .toList();

      developer.log(
        'getAllReports: Retrieved ${reports.length} reports',
        name: 'ReportsRemoteDataSource',
      );
      return reports;
    } on DioException catch (e) {
      developer.log(
        'getAllReports error: ${e.message}',
        error: e,
        name: 'ReportsRemoteDataSource',
      );
      throw ServerException(message: e.message ?? 'Failed to fetch reports');
    }
  }

  @override
  Future<ReportApiModel> getReportById(String reportId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.adminReportById(reportId),
      );

      final report = ReportApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      developer.log(
        'getReportById: Retrieved report $reportId',
        name: 'ReportsRemoteDataSource',
      );
      return report;
    } on DioException catch (e) {
      developer.log(
        'getReportById error: ${e.message}',
        error: e,
        name: 'ReportsRemoteDataSource',
      );
      throw ServerException(message: e.message ?? 'Failed to fetch report');
    }
  }

  @override
  Future<List<ReportApiModel>> getReportsByUser(String userId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.adminReportsByUser(userId),
      );

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      final reports = (data)
          .map((json) => ReportApiModel.fromJson(json as Map<String, dynamic>))
          .toList();

      developer.log(
        'getReportsByUser: Retrieved ${reports.length} reports for user $userId',
        name: 'ReportsRemoteDataSource',
      );
      return reports;
    } on DioException catch (e) {
      developer.log(
        'getReportsByUser error: ${e.message}',
        error: e,
        name: 'ReportsRemoteDataSource',
      );
      throw ServerException(
        message: e.message ?? 'Failed to fetch user reports',
      );
    }
  }

  @override
  Future<ReportApiModel> reviewReport({
    required String reportId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminReportReview(reportId),
        data: {'status': status, 'notes': notes},
      );

      final report = ReportApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      developer.log(
        'reviewReport: Updated report $reportId to status $status',
        name: 'ReportsRemoteDataSource',
      );
      return report;
    } on DioException catch (e) {
      developer.log(
        'reviewReport error: ${e.message}',
        error: e,
        name: 'ReportsRemoteDataSource',
      );
      throw ServerException(message: e.message ?? 'Failed to review report');
    }
  }

  @override
  Future<ReportApiModel> resolveReport({
    required String reportId,
    required String action,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.adminReportResolve(reportId),
        data: {
          'action': action, // 'warn', 'suspend', 'ban', 'dismiss'
          'notes': notes,
        },
      );

      final report = ReportApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      developer.log(
        'resolveReport: Resolved report $reportId with action $action',
        name: 'ReportsRemoteDataSource',
      );
      return report;
    } on DioException catch (e) {
      developer.log(
        'resolveReport error: ${e.message}',
        error: e,
        name: 'ReportsRemoteDataSource',
      );
      throw ServerException(message: e.message ?? 'Failed to resolve report');
    }
  }

  @override
  Future<Map<String, dynamic>> getReportStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminReportStats);

      final stats = response.data['data'] as Map<String, dynamic>;
      developer.log(
        'getReportStats: Retrieved report statistics',
        name: 'ReportsRemoteDataSource',
      );
      return stats;
    } on DioException catch (e) {
      developer.log(
        'getReportStats error: ${e.message}',
        error: e,
        name: 'ReportsRemoteDataSource',
      );
      throw ServerException(
        message: e.message ?? 'Failed to fetch report statistics',
      );
    }
  }
}

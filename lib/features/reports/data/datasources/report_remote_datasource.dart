import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/reports/data/models/report_model.dart';
import 'package:tripmates/features/reports/domain/entities/report_entity.dart';

/// Remote data source for reports API
abstract class ReportRemoteDataSource {
  Future<ReportModel> submitReport({
    required String reportedEntityType,
    required String reportedEntityId,
    required ReportReason reason,
    String? description,
  });

  Future<List<ReportModel>> getMyReports();
}

/// Implementation of ReportRemoteDataSource
class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ReportModel> submitReport({
    required String reportedEntityType,
    required String reportedEntityId,
    required ReportReason reason,
    String? description,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/reports',
        data: {
          'reportedEntityType': reportedEntityType,
          'reportedEntityId': reportedEntityId,
          'reason': reason.name,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReportModel.fromJson(response.data['report'] ?? response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to submit report',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    try {
      final response = await apiClient.get('/api/reports/my-reports');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['reports'] ?? response.data;
        return data.map((json) => ReportModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get reports',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

/// Riverpod provider
final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReportRemoteDataSourceImpl(apiClient: apiClient);
});

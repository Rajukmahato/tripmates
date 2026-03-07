import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/admin/data/models/admin_report_model.dart';
import 'package:tripmates/features/admin/data/models/admin_stats_model.dart';
import 'package:tripmates/features/admin/data/models/admin_trip_model.dart';
import 'package:tripmates/features/admin/data/models/admin_user_model.dart';

/// Remote datasource for admin operations
class AdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSource(this._apiClient);

  /// Get overview statistics
  Future<AdminStatsModel> getOverviewStats() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.adminAnalyticsOverview,
      );
      return AdminStatsModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to fetch stats',
      );
    }
  }

  /// Get all users
  Future<List<AdminUserModel>> getAllUsers() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminUsers);
      final List<dynamic> users = response.data['data'] ?? response.data;
      return users.map((json) => AdminUserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to fetch users',
      );
    }
  }

  /// Get user by ID
  Future<AdminUserModel> getUserById(String userId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminUserById(userId));
      return AdminUserModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to fetch user',
      );
    }
  }

  /// Toggle user status
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.adminUserById(userId),
        data: {'isActive': isActive},
      );
      return true;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to update user',
      );
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      await _apiClient.delete(ApiEndpoints.adminUserById(userId));
      return true;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to delete user',
      );
    }
  }

  /// Get all trips
  Future<List<AdminTripModel>> getAllTrips() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminTrips);
      final List<dynamic> trips = response.data['data'] ?? response.data;
      return trips.map((json) => AdminTripModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to fetch trips',
      );
    }
  }

  /// Get trip by ID
  Future<AdminTripModel> getTripById(String tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminTripById(tripId));
      return AdminTripModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to fetch trip',
      );
    }
  }

  /// Toggle trip status
  Future<bool> toggleTripStatus(String tripId, bool isActive) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.adminTripById(tripId),
        data: {'isActive': isActive},
      );
      return true;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to update trip',
      );
    }
  }

  /// Feature trip
  Future<bool> featureTrip(String tripId, bool isFeatured) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.adminTripById(tripId),
        data: {'isFeatured': isFeatured},
      );
      return true;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to feature trip',
      );
    }
  }

  /// Delete trip
  Future<bool> deleteTrip(String tripId) async {
    try {
      await _apiClient.delete(ApiEndpoints.adminTripById(tripId));
      return true;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to delete trip',
      );
    }
  }

  /// Get all reports
  Future<List<AdminReportModel>> getAllReports() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.adminAllReports);
      final List<dynamic> reports = response.data['data'] ?? response.data;
      return reports.map((json) => AdminReportModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to fetch reports',
      );
    }
  }

  /// Get report by ID
  Future<AdminReportModel> getReportById(String reportId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.adminReportById(reportId),
      );
      return AdminReportModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to fetch report',
      );
    }
  }

  /// Review report
  Future<bool> reviewReport(
    String reportId,
    String status,
    String? notes,
  ) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.adminReportReview(reportId),
        data: {'status': status, if (notes != null) 'adminNotes': notes},
      );
      return true;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to review report',
      );
    }
  }

  /// Resolve report
  Future<bool> resolveReport(String reportId) async {
    try {
      await _apiClient.post(ApiEndpoints.adminReportResolve(reportId));
      return true;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to resolve report',
      );
    }
  }
}

/// Provider
final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminRemoteDataSource(apiClient);
});

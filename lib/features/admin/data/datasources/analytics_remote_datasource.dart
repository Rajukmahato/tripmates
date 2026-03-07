import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/admin/data/models/analytics_model.dart';

/// Riverpod provider for analytics remote datasource
final analyticsRemoteDataSourceProvider = Provider<IAnalyticsRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return AnalyticsRemoteDataSource(apiClient: apiClient);
});

/// Abstract interface for analytics remote data source
abstract class IAnalyticsRemoteDataSource {
  /// Get platform overview statistics
  Future<PlatformOverviewModel> getOverview();

  /// Get user growth analytics for specified period
  /// [period] - 'daily', 'weekly', or 'monthly'
  Future<List<UserGrowthModel>> getUserAnalytics(String period);

  /// Get trip statistics for specified period
  /// [period] - 'daily', 'weekly', or 'monthly'
  Future<List<TripStatsModel>> getTripAnalytics(String period);

  /// Get match statistics for specified period
  /// [period] - 'daily', 'weekly', or 'monthly'
  Future<List<MatchStatsModel>> getMatchAnalytics(String period);

  /// Get system performance metrics
  Future<PerformanceMetricsModel> getPerformanceMetrics();
}

/// Implementation of analytics remote data source
class AnalyticsRemoteDataSource implements IAnalyticsRemoteDataSource {
  final ApiClient _apiClient;

  AnalyticsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<PlatformOverviewModel> getOverview() async {
    try {
      log('Fetching platform overview analytics');

      final response = await _apiClient.get(
        ApiEndpoints.adminAnalyticsOverview,
      );

      if (response.statusCode == 200) {
        final data =
            response.data['data'] as Map<String, dynamic>? ??
            response.data as Map<String, dynamic>;
        final overview = PlatformOverviewModel.fromJson(data);

        log('Platform overview fetched successfully');
        return overview;
      }

      throw ServerException(
        message:
            response.data['message'] ?? 'Failed to fetch platform overview',
      );
    } on DioException catch (e) {
      log('Error fetching platform overview: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<List<UserGrowthModel>> getUserAnalytics(String period) async {
    try {
      log('Fetching user growth analytics for period: $period');

      final response = await _apiClient.get(
        ApiEndpoints.adminAnalyticsUsers,
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['data'] as List<dynamic>? ?? [];
        final userGrowth = data
            .map(
              (item) => UserGrowthModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        log(
          'User analytics fetched successfully: ${userGrowth.length} records',
        );
        return userGrowth;
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch user analytics',
      );
    } on DioException catch (e) {
      log('Error fetching user analytics: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<List<TripStatsModel>> getTripAnalytics(String period) async {
    try {
      log('Fetching trip analytics for period: $period');

      final response = await _apiClient.get(
        ApiEndpoints.adminAnalyticsTrips,
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['data'] as List<dynamic>? ?? [];
        final tripStats = data
            .map(
              (item) => TripStatsModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        log('Trip analytics fetched successfully: ${tripStats.length} records');
        return tripStats;
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch trip analytics',
      );
    } on DioException catch (e) {
      log('Error fetching trip analytics: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<List<MatchStatsModel>> getMatchAnalytics(String period) async {
    try {
      log('Fetching match analytics for period: $period');

      final response = await _apiClient.get(
        ApiEndpoints.adminAnalyticsMatches,
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['data'] as List<dynamic>? ?? [];
        final matchStats = data
            .map(
              (item) => MatchStatsModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        log(
          'Match analytics fetched successfully: ${matchStats.length} records',
        );
        return matchStats;
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch match analytics',
      );
    } on DioException catch (e) {
      log('Error fetching match analytics: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }

  @override
  Future<PerformanceMetricsModel> getPerformanceMetrics() async {
    try {
      log('Fetching performance metrics');

      final response = await _apiClient.get(
        ApiEndpoints.adminAnalyticsPerformance,
      );

      if (response.statusCode == 200) {
        final data =
            response.data['data'] as Map<String, dynamic>? ??
            response.data as Map<String, dynamic>;
        final metrics = PerformanceMetricsModel.fromJson(data);

        log('Performance metrics fetched successfully');
        return metrics;
      }

      throw ServerException(
        message:
            response.data['message'] ?? 'Failed to fetch performance metrics',
      );
    } on DioException catch (e) {
      log('Error fetching performance metrics: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }
}

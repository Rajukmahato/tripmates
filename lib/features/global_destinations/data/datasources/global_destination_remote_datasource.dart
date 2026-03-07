import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/global_destinations/data/models/global_destination_api_model.dart';

/// Provider for global destination remote datasource
final globalDestinationRemoteDataSourceProvider =
    Provider<IGlobalDestinationRemoteDataSource>((ref) {
      final apiClient = ref.read(apiClientProvider);
      return GlobalDestinationRemoteDataSource(apiClient: apiClient);
    });

/// Remote datasource interface for global destinations
abstract interface class IGlobalDestinationRemoteDataSource {
  Future<List<GlobalDestinationApiModel>> getAllDestinations({
    bool includeInactive = false,
  });

  Future<List<GlobalDestinationApiModel>> searchDestinations({
    required String query,
    bool includeInactive = false,
  });

  Future<GlobalDestinationApiModel> getDestinationById(String id);

  Future<GlobalDestinationApiModel> createDestination(
    Map<String, dynamic> data,
  );

  Future<GlobalDestinationApiModel> updateDestination(
    String id,
    Map<String, dynamic> data,
  );

  Future<void> deleteDestination(String id);

  Future<GlobalDestinationApiModel> toggleDestinationStatus(String id);

  Future<Map<String, dynamic>> getDestinationStats();
}

/// Remote datasource implementation
class GlobalDestinationRemoteDataSource
    implements IGlobalDestinationRemoteDataSource {
  final ApiClient _apiClient;

  GlobalDestinationRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<GlobalDestinationApiModel>> getAllDestinations({
    bool includeInactive = false,
  }) async {
    try {
      final queryParams = includeInactive ? '?includeInactive=true' : '';
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.destinations}$queryParams',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return data
              .map((json) => GlobalDestinationApiModel.fromJson(json))
              .toList();
        }
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch destinations',
      );
    } on DioException catch (e) {
      // Handle different error response formats
      String errorMessage = 'Network error occurred';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<GlobalDestinationApiModel>> searchDestinations({
    required String query,
    bool includeInactive = false,
  }) async {
    try {
      final queryParams = {
        'name': query,
        if (includeInactive) 'includeInactive': 'true',
      };

      final response = await _apiClient.dio.get(
        ApiEndpoints.destinationsSearch,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return data
              .map((json) => GlobalDestinationApiModel.fromJson(json))
              .toList();
        }
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to search destinations',
      );
    } on DioException catch (e) {
      // Handle different error response formats
      String errorMessage = 'Network error occurred';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<GlobalDestinationApiModel> getDestinationById(String id) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.destinationById(id),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return GlobalDestinationApiModel.fromJson(data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch destination',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<GlobalDestinationApiModel> createDestination(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.destinations,
        data: data,
      );

      if (response.data['success'] == true) {
        final destinationData = response.data['data'];
        return GlobalDestinationApiModel.fromJson(destinationData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to create destination',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<GlobalDestinationApiModel> updateDestination(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.destinationById(id),
        data: data,
      );

      if (response.data['success'] == true) {
        final destinationData = response.data['data'];
        return GlobalDestinationApiModel.fromJson(destinationData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to update destination',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteDestination(String id) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.destinationById(id),
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete destination',
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
  Future<GlobalDestinationApiModel> toggleDestinationStatus(String id) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiEndpoints.destinationById(id)}/status',
      );

      if (response.data['success'] == true) {
        final destinationData = response.data['data'];
        return GlobalDestinationApiModel.fromJson(destinationData);
      }

      throw ServerException(
        message:
            response.data['message'] ?? 'Failed to toggle destination status',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getDestinationStats() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.adminDestinations);

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch statistics',
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

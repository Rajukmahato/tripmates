import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/location/data/models/location_api_model.dart';

/// Provider for location remote datasource
final locationRemoteDataSourceProvider = Provider<ILocationRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return LocationRemoteDataSource(apiClient: apiClient);
});

/// Remote datasource interface for location sharing
abstract interface class ILocationRemoteDataSource {
  /// Start location sharing for a trip
  Future<void> startLocationSharing({
    required String tripId,
    required double latitude,
    required double longitude,
  });

  /// Update current location
  Future<void> updateLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  });

  /// Stop location sharing
  Future<void> stopLocationSharing(String tripId);

  /// Get locations for all members of a trip
  Future<List<LocationApiModel>> getTripLocations(String tripId);

  /// Get nearby places (optional feature)
  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
  });

  /// Get route between two points (optional feature)
  Future<Map<String, dynamic>> getRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  });
}

/// Remote datasource implementation
class LocationRemoteDataSource implements ILocationRemoteDataSource {
  final ApiClient _apiClient;

  LocationRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<void> startLocationSharing({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.locationShare,
        data: {'tripId': tripId, 'latitude': latitude, 'longitude': longitude},
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to start location sharing',
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
  Future<void> updateLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.locationUpdate,
        data: {'tripId': tripId, 'latitude': latitude, 'longitude': longitude},
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update location',
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
  Future<void> stopLocationSharing(String tripId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.locationStop,
        data: {'tripId': tripId},
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to stop location sharing',
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
  Future<List<LocationApiModel>> getTripLocations(String tripId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.locationByTrip(tripId),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return data.map((json) => LocationApiModel.fromJson(json)).toList();
        }
        return [];
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch trip locations',
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
  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.locationNearby,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'type': type,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch nearby places',
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
  Future<Map<String, dynamic>> getRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.locationRoute,
        queryParameters: {
          'startLat': startLatitude,
          'startLng': startLongitude,
          'endLat': endLatitude,
          'endLng': endLongitude,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>? ?? {};
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to fetch route',
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

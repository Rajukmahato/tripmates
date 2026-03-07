import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/trip/data/models/trip_api_model.dart';

final tripRemoteDatasourceProvider = Provider<ITripRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return TripRemoteDatasource(apiClient: apiClient);
});

/// Pagination response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
  });
}

abstract interface class ITripRemoteDataSource {
  /// Get all trips with pagination
  Future<PaginatedResponse<TripApiModel>> getAllTrips({
    int page = 1,
    int limit = 10,
  });

  /// Get a specific trip by ID
  Future<TripApiModel> getTripById(String tripId);

  /// Create a new trip
  Future<TripApiModel> createTrip({
    required Map<String, dynamic> tripData,
    List<String>? imagePaths,
  });

  /// Update an existing trip
  Future<TripApiModel> updateTrip({
    required String tripId,
    required Map<String, dynamic> tripData,
    List<String>? imagePaths,
  });

  /// Delete a trip
  Future<void> deleteTrip(String tripId);

  /// Search trips with filters
  Future<PaginatedResponse<TripApiModel>> searchTrips({
    String? destination,
    String? travelType,
    double? minBudget,
    double? maxBudget,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  });

  /// Get trips by creator/user ID
  Future<PaginatedResponse<TripApiModel>> getTripsByCreator({
    required String userId,
    int page = 1,
    int limit = 10,
    String? status,
  });

  /// Get trips the user has joined (user is a member)
  Future<PaginatedResponse<TripApiModel>> getJoinedTrips({
    required String userId,
    int page = 1,
    int limit = 10,
    String? status,
  });

  /// Get trip itinerary
  Future<List<Map<String, dynamic>>> getItinerary(String tripId);

  /// Update trip itinerary
  Future<void> updateItinerary({
    required String tripId,
    required List<Map<String, dynamic>> itinerary,
  });

  /// Get trip checklist
  Future<List<Map<String, dynamic>>> getChecklist(String tripId);

  /// Update trip checklist
  Future<void> updateChecklist({
    required String tripId,
    required List<Map<String, dynamic>> checklist,
  });

  /// Send join request for a trip
  Future<void> sendJoinRequest({
    required String tripId,
    required String userId,
    String? message,
  });
}

class TripRemoteDatasource implements ITripRemoteDataSource {
  final ApiClient _apiClient;

  TripRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Helper to safely parse int from dynamic value
  int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  @override
  Future<PaginatedResponse<TripApiModel>> getAllTrips({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.trips,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final trips = data
            .map((json) => TripApiModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final pagination = response.data['pagination'] as Map<String, dynamic>?;

        return PaginatedResponse(
          data: trips,
          currentPage: _parseInt(pagination?['currentPage'], page),
          totalPages: _parseInt(pagination?['totalPages'], 1),
          totalCount: _parseInt(pagination?['totalCount'], trips.length),
          limit: _parseInt(pagination?['limit'], limit),
        );
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get trips',
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
  Future<TripApiModel> getTripById(String tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.tripById(tripId));

      if (response.data['success'] == true) {
        final tripData = response.data['data'] as Map<String, dynamic>;
        return TripApiModel.fromJson(tripData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get trip',
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
  Future<TripApiModel> createTrip({
    required Map<String, dynamic> tripData,
    List<String>? imagePaths,
  }) async {
    print('🟣 [TripRemoteDatasource] createTrip called');
    print('   Trip data: $tripData');
    print('   Image paths: $imagePaths');
    try {
      if (imagePaths != null && imagePaths.isNotEmpty) {
        // Create FormData for multipart upload with images
        final Map<String, dynamic> fields = {};

        // Add all trip data fields
        tripData.forEach((key, value) {
          if (value != null) {
            if (value is List) {
              // Handle arrays (convert to JSON string for multipart)
              fields[key] = value.map((e) => e.toString()).join(',');
            } else if (value is DateTime) {
              fields[key] = value.toIso8601String();
            } else if (value is Map) {
              // Convert nested objects to JSON string for multipart
              fields[key] = jsonEncode(value);
            } else {
              fields[key] = value.toString();
            }
          }
        });

        // Add image files
        final List<MultipartFile> imageFiles = [];
        for (final path in imagePaths) {
          imageFiles.add(await MultipartFile.fromFile(path));
        }

        final formData = FormData.fromMap({...fields, 'images': imageFiles});

        final response = await _apiClient.post(
          ApiEndpoints.trips,
          data: formData,
        );

        if (response.data['success'] == true) {
          final tripData = response.data['data'] as Map<String, dynamic>;
          return TripApiModel.fromJson(tripData);
        }

        throw ServerException(
          message: response.data['message'] ?? 'Failed to create trip',
        );
      } else {
        // Send as raw JSON without images
        print(
          '🟣 [TripRemoteDatasource] Sending POST to ${ApiEndpoints.trips}',
        );
        final response = await _apiClient.post(
          ApiEndpoints.trips,
          data: tripData,
        );

        print(
          '🟣 [TripRemoteDatasource] Response received: ${response.statusCode}',
        );
        print('   Success: ${response.data['success']}');

        if (response.data['success'] == true) {
          final tripData = response.data['data'] as Map<String, dynamic>;
          print('✅ [TripRemoteDatasource] Trip created successfully');
          return TripApiModel.fromJson(tripData);
        }

        throw ServerException(
          message: response.data['message'] ?? 'Failed to create trip',
        );
      }
    } on DioException catch (e) {
      print('❌ [TripRemoteDatasource] DioException: ${e.message}');
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      print('❌ [TripRemoteDatasource] Generic error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TripApiModel> updateTrip({
    required String tripId,
    required Map<String, dynamic> tripData,
    List<String>? imagePaths,
  }) async {
    try {
      if (imagePaths != null && imagePaths.isNotEmpty) {
        // Create FormData for multipart upload with images
        final Map<String, dynamic> fields = {};

        // Add all trip data fields
        tripData.forEach((key, value) {
          if (value != null) {
            if (value is List) {
              fields[key] = value.map((e) => e.toString()).join(',');
            } else if (value is DateTime) {
              fields[key] = value.toIso8601String();
            } else if (value is Map) {
              // Convert nested objects to JSON string for multipart
              fields[key] = jsonEncode(value);
            } else {
              fields[key] = value.toString();
            }
          }
        });

        // Add image files
        final List<MultipartFile> imageFiles = [];
        for (final path in imagePaths) {
          imageFiles.add(await MultipartFile.fromFile(path));
        }

        final formData = FormData.fromMap({...fields, 'images': imageFiles});

        final response = await _apiClient.put(
          ApiEndpoints.tripById(tripId),
          data: formData,
        );

        if (response.data['success'] == true) {
          final tripData = response.data['data'] as Map<String, dynamic>;
          return TripApiModel.fromJson(tripData);
        }

        throw ServerException(
          message: response.data['message'] ?? 'Failed to update trip',
        );
      } else {
        // Send as raw JSON without images
        final response = await _apiClient.put(
          ApiEndpoints.tripById(tripId),
          data: tripData,
        );

        if (response.data['success'] == true) {
          final tripData = response.data['data'] as Map<String, dynamic>;
          return TripApiModel.fromJson(tripData);
        }

        throw ServerException(
          message: response.data['message'] ?? 'Failed to update trip',
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
  Future<void> deleteTrip(String tripId) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.tripById(tripId));

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete trip',
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
  Future<PaginatedResponse<TripApiModel>> searchTrips({
    String? destination,
    String? travelType,
    double? minBudget,
    double? maxBudget,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      if (destination != null && destination.isNotEmpty) {
        queryParams['destination'] = destination;
      }
      if (travelType != null && travelType.isNotEmpty) {
        queryParams['travelType'] = travelType;
      }
      if (minBudget != null) {
        queryParams['minBudget'] = minBudget;
      }
      if (maxBudget != null) {
        queryParams['maxBudget'] = maxBudget;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        ApiEndpoints.tripsSearch,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final trips = data
            .map((json) => TripApiModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final pagination = response.data['pagination'] as Map<String, dynamic>?;

        return PaginatedResponse(
          data: trips,
          currentPage: _parseInt(pagination?['currentPage'], page),
          totalPages: _parseInt(pagination?['totalPages'], 1),
          totalCount: _parseInt(pagination?['totalCount'], trips.length),
          limit: _parseInt(pagination?['limit'], limit),
        );
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to search trips',
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
  Future<PaginatedResponse<TripApiModel>> getTripsByCreator({
    required String userId,
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      // Don't filter by status - get all trips
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        ApiEndpoints.tripsByUser(userId),
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final trips = data
            .map((json) => TripApiModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final pagination = response.data['pagination'] as Map<String, dynamic>?;

        return PaginatedResponse(
          data: trips,
          currentPage: _parseInt(pagination?['currentPage'], page),
          totalPages: _parseInt(pagination?['totalPages'], 1),
          totalCount: _parseInt(pagination?['totalCount'], trips.length),
          limit: _parseInt(pagination?['limit'], limit),
        );
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get trips',
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
  Future<PaginatedResponse<TripApiModel>> getJoinedTrips({
    required String userId,
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      // Don't filter by status - get all trips
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // API endpoint for trips user has joined
      final response = await _apiClient.get(
        '/trips/joined/$userId',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final trips = data
            .map((json) => TripApiModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final pagination = response.data['pagination'] as Map<String, dynamic>?;

        return PaginatedResponse(
          data: trips,
          currentPage: _parseInt(pagination?['currentPage'], page),
          totalPages: _parseInt(pagination?['totalPages'], 1),
          totalCount: _parseInt(pagination?['totalCount'], trips.length),
          limit: _parseInt(pagination?['limit'], limit),
        );
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get joined trips',
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
  Future<List<Map<String, dynamic>>> getItinerary(String tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.tripItinerary(tripId));

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('itinerary')) {
          return (data['itinerary'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get itinerary',
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
  Future<void> updateItinerary({
    required String tripId,
    required List<Map<String, dynamic>> itinerary,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.tripItinerary(tripId),
        data: {'itinerary': itinerary},
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update itinerary',
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
  Future<List<Map<String, dynamic>>> getChecklist(String tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.tripChecklist(tripId));

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('checklist')) {
          return (data['checklist'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get checklist',
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
  Future<void> updateChecklist({
    required String tripId,
    required List<Map<String, dynamic>> checklist,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.tripChecklist(tripId),
        data: {'checklist': checklist},
      );

      if (response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update checklist',
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
  Future<void> sendJoinRequest({
    required String tripId,
    required String userId,
    String? message,
  }) async {
    try {
      // Send partner request to the correct endpoint
      // Backend will determine the trip creator automatically
      final response = await _apiClient.post(
        '/partner-requests',
        data: {'tripId': tripId, if (message != null) 'message': message},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to send join request',
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

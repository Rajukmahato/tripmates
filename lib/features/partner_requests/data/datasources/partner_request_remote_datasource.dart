import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/partner_requests/data/models/partner_request_model.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';

/// Remote data source for partner requests API
abstract class PartnerRequestRemoteDataSource {
  Future<PartnerRequestModel> sendRequest({
    required String receiverId,
    required String tripId,
    String? message,
  });

  Future<List<PartnerRequestModel>> getRequests({
    String? filter,
    String? status,
  });

  Future<PartnerRequestModel> acceptRequest(String requestId);

  Future<PartnerRequestModel> rejectRequest(String requestId);

  Future<void> cancelRequest(String requestId);

  Future<int> getPendingCount();
}

/// Implementation of PartnerRequestRemoteDataSource
class PartnerRequestRemoteDataSourceImpl
    implements PartnerRequestRemoteDataSource {
  final ApiClient apiClient;

  PartnerRequestRemoteDataSourceImpl({required this.apiClient});

  /// Helper method to convert string status to RequestStatus enum
  RequestStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }

  @override
  Future<PartnerRequestModel> sendRequest({
    required String receiverId,
    required String tripId,
    String? message,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.partnerRequests,
        data: {'tripId': tripId, if (message != null) 'message': message},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PartnerRequestModel.fromJson(
          response.data['request'] ?? response.data['data'] ?? response.data,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to send request',
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
  Future<List<PartnerRequestModel>> getRequests({
    String? filter,
    String? status,
  }) async {
    try {
      String endpoint;

      // Use specific endpoints based on filter
      if (filter == 'sent') {
        endpoint = ApiEndpoints.partnerRequestsSent;
      } else if (filter == 'received') {
        endpoint = ApiEndpoints.partnerRequestsReceived;
      } else {
        // For 'all' or null, fetch both and merge
        final receivedFuture = apiClient.get(
          ApiEndpoints.partnerRequestsReceived,
        );
        final sentFuture = apiClient.get(ApiEndpoints.partnerRequestsSent);

        final responses = await Future.wait([receivedFuture, sentFuture]);

        final List<PartnerRequestModel> allRequests = [];

        for (final response in responses) {
          if (response.statusCode == 200) {
            final List<dynamic> data =
                response.data['requests'] ??
                response.data['data'] ??
                response.data;
            allRequests.addAll(
              data.map((json) => PartnerRequestModel.fromJson(json)),
            );
          }
        }

        // Filter by status if provided
        if (status != null) {
          final statusEnum = _statusFromString(status);
          return allRequests.where((req) => req.status == statusEnum).toList();
        }

        return allRequests;
      }

      // Single endpoint call for specific filter
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['requests'] ?? response.data['data'] ?? response.data;
        return data.map((json) => PartnerRequestModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get requests',
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
  Future<PartnerRequestModel> acceptRequest(String requestId) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.partnerRequestStatus(requestId),
        data: {'status': 'accepted'},
      );

      if (response.statusCode == 200) {
        return PartnerRequestModel.fromJson(
          response.data['data'] ?? response.data['request'] ?? response.data,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to accept request',
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
  Future<PartnerRequestModel> rejectRequest(String requestId) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.partnerRequestStatus(requestId),
        data: {'status': 'rejected'},
      );

      if (response.statusCode == 200) {
        return PartnerRequestModel.fromJson(
          response.data['data'] ?? response.data['request'] ?? response.data,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to reject request',
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
  Future<void> cancelRequest(String requestId) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.partnerRequestById(requestId),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to cancel request',
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
  Future<int> getPendingCount() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.partnerRequestsReceived,
        queryParameters: {'status': 'pending', 'page': 1, 'limit': 1},
      );

      if (response.statusCode == 200) {
        final pagination = response.data['pagination'] as Map<String, dynamic>?;
        if (pagination != null && pagination['totalCount'] != null) {
          return pagination['totalCount'] as int;
        }

        final data = response.data['data'];
        if (data is List) {
          return data.length;
        }
        return 0;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get pending count',
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
final partnerRequestRemoteDataSourceProvider =
    Provider<PartnerRequestRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return PartnerRequestRemoteDataSourceImpl(apiClient: apiClient);
    });

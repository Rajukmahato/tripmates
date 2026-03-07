import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/reviews/data/models/review_model.dart';

/// Remote data source for reviews API
abstract class ReviewRemoteDataSource {
  Future<ReviewModel> createReview({
    required String tripId,
    required String revieweeId,
    required double rating,
    String? comment,
  });

  Future<List<ReviewModel>> getReviewsByTrip(String tripId);

  Future<List<ReviewModel>> getReviewsByUser(String userId);

  Future<ReviewModel> updateReview({
    required String reviewId,
    required double rating,
    String? comment,
  });

  Future<void> deleteReview(String reviewId);

  Future<Map<String, dynamic>> getUserRatingStats(String userId);
}

/// Implementation of ReviewRemoteDataSource
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ReviewModel> createReview({
    required String tripId,
    required String revieweeId,
    required double rating,
    String? comment,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/reviews',
        data: {
          'tripId': tripId,
          'revieweeId': revieweeId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReviewModel.fromJson(response.data['review'] ?? response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create review',
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
  Future<List<ReviewModel>> getReviewsByTrip(String tripId) async {
    try {
      final response = await apiClient.get('/api/reviews/trip/$tripId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['reviews'] ?? response.data;
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get reviews',
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
  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    try {
      final response = await apiClient.get('/api/reviews/user/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['reviews'] ?? response.data;
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get reviews',
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
  Future<ReviewModel> updateReview({
    required String reviewId,
    required double rating,
    String? comment,
  }) async {
    try {
      final response = await apiClient.put(
        '/api/reviews/$reviewId',
        data: {'rating': rating, if (comment != null) 'comment': comment},
      );

      if (response.statusCode == 200) {
        return ReviewModel.fromJson(response.data['review'] ?? response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update review',
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
  Future<void> deleteReview(String reviewId) async {
    try {
      final response = await apiClient.delete('/api/reviews/$reviewId');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete review',
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
  Future<Map<String, dynamic>> getUserRatingStats(String userId) async {
    try {
      final response = await apiClient.get('/api/reviews/user/$userId/stats');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get rating stats',
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
final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewRemoteDataSourceImpl(apiClient: apiClient);
});

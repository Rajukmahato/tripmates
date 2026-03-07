import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:tripmates/features/reviews/domain/entities/review_entity.dart';
import 'package:tripmates/features/reviews/domain/repositories/review_repository.dart';

/// Implementation of ReviewRepository
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    required String tripId,
    required String revieweeId,
    required double rating,
    String? comment,
  }) async {
    try {
      final review = await remoteDataSource.createReview(
        tripId: tripId,
        revieweeId: revieweeId,
        rating: rating,
        comment: comment,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to create review'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByTrip(
    String tripId,
  ) async {
    try {
      final reviews = await remoteDataSource.getReviewsByTrip(tripId);
      return Right(reviews);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get reviews'));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByUser(
    String userId,
  ) async {
    try {
      final reviews = await remoteDataSource.getReviewsByUser(userId);
      return Right(reviews);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get reviews'));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> updateReview({
    required String reviewId,
    required double rating,
    String? comment,
  }) async {
    try {
      final review = await remoteDataSource.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to update review'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to delete review'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserRatingStats(
    String userId,
  ) async {
    try {
      final stats = await remoteDataSource.getUserRatingStats(userId);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get rating stats'));
    }
  }
}

/// Riverpod provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final remoteDataSource = ref.watch(reviewRemoteDataSourceProvider);
  return ReviewRepositoryImpl(remoteDataSource: remoteDataSource);
});

import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reviews/domain/entities/review_entity.dart';

/// Abstract repository for review operations
abstract class ReviewRepository {
  Future<Either<Failure, ReviewEntity>> createReview({
    required String tripId,
    required String revieweeId,
    required double rating,
    String? comment,
  });

  Future<Either<Failure, List<ReviewEntity>>> getReviewsByTrip(String tripId);

  Future<Either<Failure, List<ReviewEntity>>> getReviewsByUser(String userId);

  Future<Either<Failure, ReviewEntity>> updateReview({
    required String reviewId,
    required double rating,
    String? comment,
  });

  Future<Either<Failure, void>> deleteReview(String reviewId);

  Future<Either<Failure, Map<String, dynamic>>> getUserRatingStats(
    String userId,
  );
}

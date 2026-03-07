import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:tripmates/features/reviews/domain/entities/review_entity.dart';
import 'package:tripmates/features/reviews/domain/repositories/review_repository.dart';

/// Use case for creating a review
class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<Either<Failure, ReviewEntity>> call({
    required String tripId,
    required String revieweeId,
    required double rating,
    String? comment,
  }) async {
    return await repository.createReview(
      tripId: tripId,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
    );
  }
}

/// Riverpod provider
final createReviewUseCaseProvider = Provider<CreateReviewUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return CreateReviewUseCase(repository);
});

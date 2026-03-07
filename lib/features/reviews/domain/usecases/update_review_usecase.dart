import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:tripmates/features/reviews/domain/entities/review_entity.dart';
import 'package:tripmates/features/reviews/domain/repositories/review_repository.dart';

/// Use case for updating a review
class UpdateReviewUseCase {
  final ReviewRepository repository;

  UpdateReviewUseCase(this.repository);

  Future<Either<Failure, ReviewEntity>> call({
    required String reviewId,
    required double rating,
    String? comment,
  }) async {
    return await repository.updateReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
    );
  }
}

/// Riverpod provider
final updateReviewUseCaseProvider = Provider<UpdateReviewUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return UpdateReviewUseCase(repository);
});

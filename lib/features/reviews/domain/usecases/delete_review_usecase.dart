import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:tripmates/features/reviews/domain/repositories/review_repository.dart';

/// Use case for deleting a review
class DeleteReviewUseCase {
  final ReviewRepository repository;

  DeleteReviewUseCase(this.repository);

  Future<Either<Failure, void>> call(String reviewId) async {
    return await repository.deleteReview(reviewId);
  }
}

/// Riverpod provider
final deleteReviewUseCaseProvider = Provider<DeleteReviewUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return DeleteReviewUseCase(repository);
});

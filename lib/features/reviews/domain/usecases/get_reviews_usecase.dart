import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:tripmates/features/reviews/domain/entities/review_entity.dart';
import 'package:tripmates/features/reviews/domain/repositories/review_repository.dart';

/// Use case for getting reviews
class GetReviewsUseCase {
  final ReviewRepository repository;

  GetReviewsUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> getByTrip(String tripId) async {
    return await repository.getReviewsByTrip(tripId);
  }

  Future<Either<Failure, List<ReviewEntity>>> getByUser(String userId) async {
    return await repository.getReviewsByUser(userId);
  }
}

/// Riverpod provider
final getReviewsUseCaseProvider = Provider<GetReviewsUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetReviewsUseCase(repository);
});

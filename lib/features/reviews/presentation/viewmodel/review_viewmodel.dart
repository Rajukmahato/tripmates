import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/reviews/domain/usecases/create_review_usecase.dart';
import 'package:tripmates/features/reviews/domain/usecases/delete_review_usecase.dart';
import 'package:tripmates/features/reviews/domain/usecases/get_reviews_usecase.dart';
import 'package:tripmates/features/reviews/domain/usecases/update_review_usecase.dart';
import 'package:tripmates/features/reviews/presentation/state/review_state.dart';

/// ViewModel for reviews
class ReviewViewmodel extends Notifier<ReviewState> {
  late final CreateReviewUseCase _createReviewUseCase;
  late final GetReviewsUseCase _getReviewsUseCase;
  late final UpdateReviewUseCase _updateReviewUseCase;
  late final DeleteReviewUseCase _deleteReviewUseCase;

  @override
  ReviewState build() {
    _createReviewUseCase = ref.watch(createReviewUseCaseProvider);
    _getReviewsUseCase = ref.watch(getReviewsUseCaseProvider);
    _updateReviewUseCase = ref.watch(updateReviewUseCaseProvider);
    _deleteReviewUseCase = ref.watch(deleteReviewUseCaseProvider);
    return const ReviewState();
  }

  /// Load reviews by trip
  Future<void> loadReviewsByTrip(String tripId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _getReviewsUseCase.getByTrip(tripId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (reviews) {
        state = state.copyWith(reviews: reviews, isLoading: false, error: null);
      },
    );
  }

  /// Load reviews by user
  Future<void> loadReviewsByUser(String userId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _getReviewsUseCase.getByUser(userId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (reviews) {
        state = state.copyWith(reviews: reviews, isLoading: false, error: null);
      },
    );
  }

  /// Create a review
  Future<bool> createReview({
    required String tripId,
    required String revieweeId,
    required double rating,
    String? comment,
  }) async {
    final result = await _createReviewUseCase(
      tripId: tripId,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (review) {
        state = state.copyWith(reviews: [review, ...state.reviews]);
        return true;
      },
    );
  }

  /// Update a review
  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    String? comment,
  }) async {
    final result = await _updateReviewUseCase(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedReview) {
        final updatedList = state.reviews.map((review) {
          return review.id == reviewId ? updatedReview : review;
        }).toList();

        state = state.copyWith(reviews: updatedList);
        return true;
      },
    );
  }

  /// Delete a review
  Future<bool> deleteReview(String reviewId) async {
    final result = await _deleteReviewUseCase(reviewId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        final updatedList = state.reviews
            .where((review) => review.id != reviewId)
            .toList();
        state = state.copyWith(reviews: updatedList);
        return true;
      },
    );
  }

  /// Reset state
  void resetState() {
    state = const ReviewState();
  }
}

/// Provider
final reviewViewmodelProvider = NotifierProvider<ReviewViewmodel, ReviewState>(
  () => ReviewViewmodel(),
);

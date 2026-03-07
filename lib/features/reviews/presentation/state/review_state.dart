import 'package:equatable/equatable.dart';
import 'package:tripmates/features/reviews/domain/entities/review_entity.dart';

/// State for reviews feature
class ReviewState extends Equatable {
  final List<ReviewEntity> reviews;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? ratingStats; // averageRating, totalReviews, etc.

  const ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.ratingStats,
  });

  ReviewState copyWith({
    List<ReviewEntity>? reviews,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? ratingStats,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      ratingStats: ratingStats ?? this.ratingStats,
    );
  }

  double get averageRating {
    if (ratingStats != null && ratingStats!['averageRating'] != null) {
      return (ratingStats!['averageRating'] as num).toDouble();
    }
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  int get totalReviews {
    if (ratingStats != null && ratingStats!['totalReviews'] != null) {
      return ratingStats!['totalReviews'] as int;
    }
    return reviews.length;
  }

  @override
  List<Object?> get props => [reviews, isLoading, error, ratingStats];
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/features/reviews/presentation/viewmodel/review_viewmodel.dart';
import 'package:tripmates/features/reviews/presentation/state/review_state.dart';
import 'package:tripmates/features/reviews/presentation/widgets/review_card.dart';
import 'package:tripmates/features/reviews/presentation/widgets/review_form_dialog.dart';
import 'package:tripmates/features/reviews/presentation/widgets/star_rating_widget.dart';

/// Reviews page for displaying trip or user reviews
class ReviewsPage extends ConsumerStatefulWidget {
  final String? tripId;
  final String? userId;
  final String? currentUserId; // For checking own reviews

  const ReviewsPage({super.key, this.tripId, this.userId, this.currentUserId});

  @override
  ConsumerState<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  void _loadReviews() {
    if (widget.tripId != null) {
      ref
          .read(reviewViewmodelProvider.notifier)
          .loadReviewsByTrip(widget.tripId!);
    } else if (widget.userId != null) {
      ref
          .read(reviewViewmodelProvider.notifier)
          .loadReviewsByUser(widget.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewViewmodelProvider);
    final viewmodel = ref.read(reviewViewmodelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (widget.tripId != null) {
            await viewmodel.loadReviewsByTrip(widget.tripId!, refresh: true);
          } else if (widget.userId != null) {
            await viewmodel.loadReviewsByUser(widget.userId!, refresh: true);
          }
        },
        child: _buildBody(state, viewmodel),
      ),
      floatingActionButton: widget.tripId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showReviewForm(context, viewmodel),
              icon: const Icon(Icons.rate_review),
              label: const Text('Write Review'),
            )
          : null,
    );
  }

  Widget _buildBody(ReviewState state, ReviewViewmodel viewmodel) {
    if (state.isLoading && state.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.reviews.isEmpty) {
      return _buildErrorState(state.error!, viewmodel);
    }

    if (state.reviews.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Rating summary
        _buildRatingSummary(state),
        const Divider(height: 1),

        // Reviews list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.reviews.length,
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              final isOwnReview =
                  widget.currentUserId != null &&
                  review.reviewerId == widget.currentUserId;

              return ReviewCard(
                review: review,
                showTripInfo: widget.userId != null,
                isOwnReview: isOwnReview,
                onEdit: () => _showEditReviewForm(context, viewmodel, review),
                onDelete: () =>
                    _handleDeleteReview(context, viewmodel, review.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSummary(ReviewState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                state.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ 5.0',
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StarRatingWidget(rating: state.averageRating, size: 28),
          const SizedBox(height: 8),
          Text(
            '${state.totalReviews} ${state.totalReviews == 1 ? 'review' : 'reviews'}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to write a review!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ReviewViewmodel viewmodel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (widget.tripId != null) {
                viewmodel.loadReviewsByTrip(widget.tripId!, refresh: true);
              } else if (widget.userId != null) {
                viewmodel.loadReviewsByUser(widget.userId!, refresh: true);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReviewForm(
    BuildContext context,
    ReviewViewmodel viewmodel,
  ) async {
    if (widget.tripId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReviewFormDialog(
        tripId: widget.tripId!,
        revieweeId: '', // Should be passed from trip details
        onSubmit: ({required rating, comment}) async {
          return await viewmodel.createReview(
            tripId: widget.tripId!,
            revieweeId: '', // Should be passed from trip details
            rating: rating,
            comment: comment,
          );
        },
      ),
    );

    if (result == true) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showEditReviewForm(
    BuildContext context,
    ReviewViewmodel viewmodel,
    review,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReviewFormDialog(
        tripId: review.tripId,
        revieweeId: review.revieweeId,
        initialRating: review.rating,
        initialComment: review.comment,
        isEdit: true,
        onSubmit: ({required rating, comment}) async {
          return await viewmodel.updateReview(
            reviewId: review.id,
            rating: rating,
            comment: comment,
          );
        },
      ),
    );

    if (result == true) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Review updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleDeleteReview(
    BuildContext context,
    ReviewViewmodel viewmodel,
    String reviewId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewmodel.deleteReview(reviewId);
      if (!mounted) return;
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Review deleted'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to delete review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

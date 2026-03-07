import 'package:flutter/material.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';

class ReviewSubmissionDialog extends StatefulWidget {
  final TripEntity trip;
  final Function(double, String) onSubmit;

  const ReviewSubmissionDialog({
    super.key,
    required this.trip,
    required this.onSubmit,
  });

  @override
  State<ReviewSubmissionDialog> createState() => _ReviewSubmissionDialogState();
}

class _ReviewSubmissionDialogState extends State<ReviewSubmissionDialog> {
  double _rating = 4.0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write a review')));
      return;
    }

    setState(() => _isSubmitting = true);

    _showLoadingDialog();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        widget.onSubmit(_rating, _reviewController.text);
        Navigator.pop(context); // Close review dialog
      }
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate This Trip'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trip Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip.tripName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.trip.destination,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Star Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Rating'),
                const SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() => _rating = index + 1.0);
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Rating: ${_rating.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Review Text
            const Text('Your Review'),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Review'),
        ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String userName;
  final double rating;
  final String reviewText;
  final DateTime reviewDate;
  final String? userImage;

  const ReviewCard({
    super.key,
    required this.userName,
    required this.rating,
    required this.reviewText,
    required this.reviewDate,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: userImage != null
                      ? NetworkImage(userImage!)
                      : null,
                  child: userImage == null
                      ? Text(userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(reviewDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rating
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 16,
                  color: index < rating.floor()
                      ? Colors.amber
                      : Colors.grey.shade300,
                );
              }),
            ),
            const SizedBox(height: 8),

            // Review Text
            Text(
              reviewText,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}

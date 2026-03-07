import 'package:equatable/equatable.dart';

/// Review entity for trip reviews and ratings
class ReviewEntity extends Equatable {
  final String id;
  final String tripId;
  final String tripTitle;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatar;
  final String revieweeId; // User being reviewed
  final String revieweeName;
  final double rating; // 1.0 to 5.0
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReviewEntity({
    required this.id,
    required this.tripId,
    required this.tripTitle,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.revieweeId,
    required this.revieweeName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  ReviewEntity copyWith({
    String? id,
    String? tripId,
    String? tripTitle,
    String? reviewerId,
    String? reviewerName,
    String? reviewerAvatar,
    String? revieweeId,
    String? revieweeName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      tripTitle: tripTitle ?? this.tripTitle,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerAvatar: reviewerAvatar ?? this.reviewerAvatar,
      revieweeId: revieweeId ?? this.revieweeId,
      revieweeName: revieweeName ?? this.revieweeName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tripId,
    tripTitle,
    reviewerId,
    reviewerName,
    reviewerAvatar,
    revieweeId,
    revieweeName,
    rating,
    comment,
    createdAt,
    updatedAt,
  ];
}

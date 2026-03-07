import 'package:tripmates/features/reviews/domain/entities/review_entity.dart';

/// Review model for API responses
class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.tripId,
    required super.tripTitle,
    required super.reviewerId,
    required super.reviewerName,
    super.reviewerAvatar,
    required super.revieweeId,
    required super.revieweeName,
    required super.rating,
    super.comment,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      tripId: json['tripId'] ?? json['trip']?['_id'] ?? '',
      tripTitle: json['tripTitle'] ?? json['trip']?['title'] ?? '',
      reviewerId: json['reviewerId'] ?? json['reviewer']?['_id'] ?? '',
      reviewerName: json['reviewerName'] ?? json['reviewer']?['name'] ?? '',
      reviewerAvatar: json['reviewerAvatar'] ?? json['reviewer']?['avatar'],
      revieweeId: json['revieweeId'] ?? json['reviewee']?['_id'] ?? '',
      revieweeName: json['revieweeName'] ?? json['reviewee']?['name'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tripId': tripId,
      'tripTitle': tripTitle,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerAvatar': reviewerAvatar,
      'revieweeId': revieweeId,
      'revieweeName': revieweeName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      tripId: entity.tripId,
      tripTitle: entity.tripTitle,
      reviewerId: entity.reviewerId,
      reviewerName: entity.reviewerName,
      reviewerAvatar: entity.reviewerAvatar,
      revieweeId: entity.revieweeId,
      revieweeName: entity.revieweeName,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

import 'package:tripmates/features/notifications/domain/entities/notification_entity.dart';

/// Notification model for API responses
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    super.data,
    required super.isRead,
    required super.createdAt,
    super.readAt,
  });

  /// Create from JSON (API response)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['recipient'] ?? json['userId'] ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['body'] ?? json['message'] ?? '',
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : json['relatedId'] != null
          ? {'relatedId': json['relatedId']}
          : null,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }

  /// Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  /// Convert from entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      title: entity.title,
      message: entity.message,
      data: entity.data,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
    );
  }

  /// Convert to entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      data: data,
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
    );
  }
}

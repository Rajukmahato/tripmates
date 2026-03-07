import 'package:equatable/equatable.dart';

/// Notification entity representing a user notification
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String type; // 'message', 'trip', 'partner_request', 'review', 'admin'
  final String title;
  final String message;
  final Map<String, dynamic>? data; // Additional data for navigation
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    message,
    data,
    isRead,
    createdAt,
    readAt,
  ];

  /// Copy with method for creating modified copies
  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

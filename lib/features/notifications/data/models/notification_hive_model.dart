import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/features/notifications/domain/entities/notification_entity.dart';

part 'notification_hive_model.g.dart';

/// Hive model for local notification storage
@HiveType(typeId: HiveTableConstant.notificationTypeId)
class NotificationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String message;

  @HiveField(5)
  final Map<dynamic, dynamic>? data;

  @HiveField(6)
  final bool isRead;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? readAt;

  NotificationHiveModel({
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

  /// Convert from entity
  factory NotificationHiveModel.fromEntity(NotificationEntity entity) {
    return NotificationHiveModel(
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
      data: data != null ? Map<String, dynamic>.from(data!) : null,
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
    );
  }
}

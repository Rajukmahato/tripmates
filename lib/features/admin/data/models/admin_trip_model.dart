import 'package:tripmates/features/admin/domain/entities/admin_trip_entity.dart';

int? _parseIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

/// Model for admin trip management
class AdminTripModel extends AdminTripEntity {
  const AdminTripModel({
    required super.id,
    required super.tripName,
    required super.destination,
    required super.creatorId,
    required super.creatorName,
    super.creatorAvatar,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.participantsCount,
    required super.maxParticipants,
    required super.reportsCount,
    required super.isFeatured,
    required super.isActive,
    required super.createdAt,
  });

  factory AdminTripModel.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'] as Map<String, dynamic>?;

    return AdminTripModel(
      id: json['_id'] as String? ?? json['id'] as String,
      tripName: json['tripName'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      creatorId:
          creator?['_id'] as String? ?? json['creatorId'] as String? ?? '',
      creatorName:
          creator?['fullName'] as String? ??
          json['creatorName'] as String? ??
          '',
      creatorAvatar: creator?['profilePicture'] as String?,
      status: json['status'] as String? ?? 'planned',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantsCount: _parseIntValue(json['participantsCount']) ?? 0,
      maxParticipants: _parseIntValue(json['maxParticipants']) ?? 10,
      reportsCount: _parseIntValue(json['reportsCount']) ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tripName': tripName,
      'destination': destination,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participantsCount': participantsCount,
      'maxParticipants': maxParticipants,
      'reportsCount': reportsCount,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AdminTripModel.fromEntity(AdminTripEntity entity) {
    return AdminTripModel(
      id: entity.id,
      tripName: entity.tripName,
      destination: entity.destination,
      creatorId: entity.creatorId,
      creatorName: entity.creatorName,
      creatorAvatar: entity.creatorAvatar,
      status: entity.status,
      startDate: entity.startDate,
      endDate: entity.endDate,
      participantsCount: entity.participantsCount,
      maxParticipants: entity.maxParticipants,
      reportsCount: entity.reportsCount,
      isFeatured: entity.isFeatured,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}

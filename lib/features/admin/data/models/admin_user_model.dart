import 'package:tripmates/features/admin/domain/entities/admin_user_entity.dart';

int? _parseIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

/// Model for admin user management
class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.profilePicture,
    super.location,
    required super.isActive,
    required super.isVerified,
    required super.role,
    required super.tripsCreated,
    required super.tripsJoined,
    required super.reportsReceived,
    required super.createdAt,
    super.lastActiveAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['_id'] as String? ?? json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
      location: json['location'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      role: json['role'] as String? ?? 'user',
      tripsCreated: _parseIntValue(json['tripsCreated']) ?? 0,
      tripsJoined: _parseIntValue(json['tripsJoined']) ?? 0,
      reportsReceived: _parseIntValue(json['reportsReceived']) ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'profilePicture': profilePicture,
      'location': location,
      'isActive': isActive,
      'isVerified': isVerified,
      'role': role,
      'tripsCreated': tripsCreated,
      'tripsJoined': tripsJoined,
      'reportsReceived': reportsReceived,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  factory AdminUserModel.fromEntity(AdminUserEntity entity) {
    return AdminUserModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      profilePicture: entity.profilePicture,
      location: entity.location,
      isActive: entity.isActive,
      isVerified: entity.isVerified,
      role: entity.role,
      tripsCreated: entity.tripsCreated,
      tripsJoined: entity.tripsJoined,
      reportsReceived: entity.reportsReceived,
      createdAt: entity.createdAt,
      lastActiveAt: entity.lastActiveAt,
    );
  }
}

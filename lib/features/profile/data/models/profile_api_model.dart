import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import '../../../../core/api/api_endpoints.dart';

String? _resolveMedia(String? media) {
  if (media == null || media.isEmpty) return null;
  if (media.startsWith('http')) return media;
  final cleaned = media.startsWith('/') ? media.substring(1) : media;
  return '${ApiEndpoints.baseOrigin}/$cleaned';
}

class ProfileApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profilePicture;
  final String? bio;
  final String? location;
  final int totalTrips;
  final int completedTrips;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profilePicture,
    this.bio,
    this.location,
    this.totalTrips = 0,
    this.completedTrips = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fullName.isNotEmpty) 'fullName': fullName,
      'email': email,
      if (phone != null && phone!.isNotEmpty) 'phoneNumber': phone,
      if (bio != null && bio!.isNotEmpty) 'bio': bio,
      if (location != null && location!.isNotEmpty) 'location': location,
    };
  }

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      id: json['_id'] as String?,
      fullName: (json['fullName'] as String?) ?? '',
      email: json['email'] as String,
      phone: (json['phoneNumber'] as String?) ?? '',
      profilePicture: _resolveMedia(json['profileImagePath'] as String?),
      bio: (json['bio'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      totalTrips: json['totalTrips'] as int? ?? 0,
      completedTrips: json['completedTrips'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: id,
      fullName: fullName,
      email: email,
      phone: phone,
      profilePicture: profilePicture,
      bio: bio,
      location: location,
      totalTrips: totalTrips,
      completedTrips: completedTrips,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProfileApiModel.fromEntity(ProfileEntity entity) {
    return ProfileApiModel(
      id: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      profilePicture: entity.profilePicture,
      bio: entity.bio,
      location: entity.location,
      totalTrips: entity.totalTrips,
      completedTrips: entity.completedTrips,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

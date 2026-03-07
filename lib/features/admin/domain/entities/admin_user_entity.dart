import 'package:equatable/equatable.dart';

/// Entity for user management in admin
class AdminUserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? profilePicture;
  final String? location;
  final bool isActive;
  final bool isVerified;
  final String role; // 'user', 'admin', etc.
  final int tripsCreated;
  final int tripsJoined;
  final int reportsReceived;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const AdminUserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePicture,
    this.location,
    required this.isActive,
    required this.isVerified,
    required this.role,
    required this.tripsCreated,
    required this.tripsJoined,
    required this.reportsReceived,
    required this.createdAt,
    this.lastActiveAt,
  });

  AdminUserEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? profilePicture,
    String? location,
    bool? isActive,
    bool? isVerified,
    String? role,
    int? tripsCreated,
    int? tripsJoined,
    int? reportsReceived,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return AdminUserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      tripsCreated: tripsCreated ?? this.tripsCreated,
      tripsJoined: tripsJoined ?? this.tripsJoined,
      reportsReceived: reportsReceived ?? this.reportsReceived,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    profilePicture,
    location,
    isActive,
    isVerified,
    role,
    tripsCreated,
    tripsJoined,
    reportsReceived,
    createdAt,
    lastActiveAt,
  ];
}

import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String? userId;
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

  const ProfileEntity({
    this.userId,
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

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    phone,
    profilePicture,
    bio,
    location,
    totalTrips,
    completedTrips,
    createdAt,
    updatedAt,
  ];
}

import 'package:equatable/equatable.dart';

/// Represents a member/participant of a trip
class TripMemberEntity extends Equatable {
  final String userId;
  final String fullName;
  final String email;
  final String? profilePicture;
  final String? role; // 'creator', 'admin', 'member'
  final DateTime? joinedAt;

  const TripMemberEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profilePicture,
    this.role,
    this.joinedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    profilePicture,
    role,
    joinedAt,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? batchId; // For sending to API
  final ProfileEntity? profile; // For displaying populated data

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.batchId,
    this.profile,
    String? profilePicture,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    phoneNumber,
    username,
    password,
    batchId,
    profile,
  ];

  String? get profilePicture => null;
}

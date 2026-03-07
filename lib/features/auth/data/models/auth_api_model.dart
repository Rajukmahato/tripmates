import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';

int? _parseIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? confirmPassword;
  final String? batchId;
  final String? profilePicture;
  final String? bio;
  final String? location;
  final String? role;
  final String? status;
  final int? totalTrips;
  final int? completedTrips;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.confirmPassword,
    this.batchId,
    this.profilePicture,
    this.bio,
    this.location,
    this.role,
    this.status,
    this.totalTrips,
    this.completedTrips,
  });

  // toJSON
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "username": username,
      "password": password,
      "confirmPassword": confirmPassword ?? password,
      "batchId": batchId,
      "profilePicture": profilePicture,
      "bio": bio,
      "location": location,
      "role": role,
      "status": status,
      "totalTrips": totalTrips,
      "completedTrips": completedTrips,
    };
  }

  // fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['userId'] as String? ?? json['_id'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      username: json['username'] as String? ?? '',
      batchId: json['batchId'] as String?,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      totalTrips: _parseIntValue(json['totalTrips']),
      completedTrips: _parseIntValue(json['completedTrips']),
    );
  }

  // toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      batchId: batchId,
      profilePicture: profilePicture,
    );
  }

  // fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      confirmPassword: entity.password,
      batchId: entity.batchId,
      profilePicture: entity.profilePicture,
    );
  }

  // toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String phoneNumber;
  final String? password;
  final String? confirmPassword;

  AuthApiModel({
    this.id,
    required this.fullName,
    this.password,
    required this.phoneNumber,
    this.confirmPassword,
  });

  //toJSON
  Map<String, dynamic> toJson() {
    return {"fullName": fullName, "phoneNumber": phoneNumber, "password": password, "confirmPassword": confirmPassword};
  }

  //fromJSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(authId: id, fullName: fullName, phoneNumber: phoneNumber, password: password, confirmPassword: confirmPassword);
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }

  //toEnitityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}


import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String phoneNumber;
  final String? password;
  final String? confirmPassword; 

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.phoneNumber,
    this.password,
    this.confirmPassword,  
  });

  @override
  List<Object?> get props => [authId, fullName, phoneNumber, password, confirmPassword];
}
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecase.dart';
import 'package:tripmates/features/auth/data/repositories/auth_repository.dart';
import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';
import 'package:tripmates/features/auth/domain/repositories/auth_repository.dart';
class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String password;
  final String? confirmPassword;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, password, confirmPassword];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;
  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
    return _authRepository.register(entity);
  }
}

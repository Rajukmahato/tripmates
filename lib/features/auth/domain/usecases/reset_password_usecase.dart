import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/auth/data/repositories/auth_repository.dart';
import 'package:tripmates/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String token;
  final String password;
  final String confirmPassword;

  const ResetPasswordParams({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, password, confirmPassword];
}

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ResetPasswordUsecase(authRepository: authRepository);
});

class ResetPasswordUsecase
    implements UsecaseWithParms<bool, ResetPasswordParams> {
  final IAuthRepository _authRepository;

  ResetPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) {
    return _authRepository.resetPassword(
      params.token,
      params.password,
      params.confirmPassword,
    );
  }
}

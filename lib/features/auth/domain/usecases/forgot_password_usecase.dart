import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/auth/data/repositories/auth_repository.dart';
import 'package:tripmates/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordParams extends Equatable {
  final String email;
  final String? platform; // 'android', 'ios', or 'web'

  const ForgotPasswordParams({required this.email, this.platform});

  @override
  List<Object?> get props => [email, platform];
}

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ForgotPasswordUsecase(authRepository: authRepository);
});

class ForgotPasswordUsecase
    implements UsecaseWithParms<bool, ForgotPasswordParams> {
  final IAuthRepository _authRepository;

  ForgotPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ForgotPasswordParams params) {
    print('🔐 [ForgotPasswordUsecase] Call with params:');
    print('   Email: ${params.email}');
    print('   Platform: ${params.platform}');
    return _authRepository.forgotPassword(
      params.email,
      platform: params.platform,
    );
  }
}

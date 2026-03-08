import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity user);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, bool>> forgotPassword(
    String email, {
    String? platform,
  });
  Future<Either<Failure, bool>> verifyOTP(String email, String otp);
  Future<Either<Failure, bool>> resetPassword(
    String token,
    String password,
    String confirmPassword,
  );
  Future<Either<Failure, bool>> resetPasswordWithOTP(
    String email,
    String otp,
    String password,
    String confirmPassword,
  );
}

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/auth/data/datasources/auth_datasource.dart';
import 'package:tripmates/features/auth/data/datasources/local/auth_local_datasources.dart';
import 'package:tripmates/features/auth/data/models/auth_hive_model.dart';
import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';
import 'package:tripmates/features/auth/domain/repositories/auth_repository.dart';

//provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  return AuthRepository(authDatasource: authDatasource);
});

class AuthRepository implements IAuthRepository {
  final IAuthDataSource _authDatasource;

  AuthRepository({required IAuthDataSource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getUserByPhoneNumber(
    String phoneNumber,
  ) async {
    try {
      final result = await _authDatasource.getUserByPhoneNumber(phoneNumber);

      if (result != null) {
        return Right(result.toEntity());
      }

      return Left(LocalDatabaseFailure(message: "User not found"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isPhoneNumberExists(String phoneNumber) async {
    try {
      final result = await _authDatasource.isPhoneNumberExists(phoneNumber);
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String phoneNumber,
    String password,
  ) async {
    try {
      final user = await _authDatasource.login(phoneNumber, password);
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(
        LocalDatabaseFailure(message: "Invalid phone number or password"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.registerUser(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Register Failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}

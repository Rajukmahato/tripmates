import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/services/connectivity/network_info.dart';
import 'package:tripmates/core/services/offline/offline_operations_queue.dart';
import 'package:tripmates/features/auth/data/datasources/auth_datasource.dart';
import 'package:tripmates/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:tripmates/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:tripmates/features/auth/data/models/auth_api_model.dart';
import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';
import 'package:tripmates/features/auth/domain/repositories/auth_repository.dart';

// Create provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final operationsQueue = ref.read(offlineOperationsQueueProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
    operationsQueue: operationsQueue,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;
  final OfflineOperationsQueue _operationsQueue;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
    required OfflineOperationsQueue operationsQueue,
  }) : _authDataSource = authDatasource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo,
       _operationsQueue = operationsQueue;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        // remote ma ja
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        // Check if email already exists locally
        final existingUser = await _authDataSource.getUserByEmail(user.email);
        if (existingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered locally"),
          );
        }

        // Queue registration for when back online
        await _operationsQueue.queueOperation(
          id: 'auth_register_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'auth',
          type: OperationType.create,
          data: {
            'action': 'register',
            'fullName': user.fullName,
            'email': user.email,
            'phoneNumber': user.phoneNumber,
            'username': user.username,
            'password': user.password,
            'batchId': user.batchId,
            'profilePicture': user.profilePicture,
          },
        );

        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid credentials"));
      } on DioException catch (e) {
        if (_isRecoverableNetworkError(e)) {
          return _attemptLocalLogin(email, password, networkFailure: true);
        }

        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return _attemptLocalLogin(email, password);
    }
  }

  Future<Either<Failure, AuthEntity>> _attemptLocalLogin(
    String email,
    String password, {
    bool networkFailure = false,
  }) async {
    try {
      // Validate credentials locally from cached Hive auth data.
      final model = await _authDataSource.login(email, password);
      if (model != null) {
        return Right(model.toEntity());
      }

      return Left(
        LocalDatabaseFailure(
          message: networkFailure
              ? 'Network issue and no matching cached credentials found. Reconnect and try again.'
              : 'Invalid credentials or no cached data. Connect to internet to login first.',
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  bool _isRecoverableNetworkError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(
    String email, {
    String? platform,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final result = await _authRemoteDataSource.forgotPassword(
          email,
          platform: platform,
        );
        if (result) {
          return const Right(true);
        }
        return const Left(ApiFailure(message: 'Failed to send reset email'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to send reset email',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        // Queue password reset request
        await _operationsQueue.queueOperation(
          id: 'auth_forgot_password_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'auth',
          type: OperationType.create,
          data: {
            'action': 'forgot_password',
            'email': email,
            if (platform != null) 'platform': platform,
          },
        );

        return const Left(
          NetworkFailure(
            message: 'Password reset queued. Will be sent when online.',
          ),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
    String token,
    String password,
    String confirmPassword,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.resetPassword(
          token,
          password,
          confirmPassword,
        );
        if (result) {
          return const Right(true);
        }
        return const Left(ApiFailure(message: 'Failed to reset password'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to reset password',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    return const Left(
      NetworkFailure(message: 'Internet connection required to reset password'),
    );
  }

  @override
  Future<Either<Failure, bool>> verifyOTP(String email, String otp) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.verifyOTP(email, otp);
        if (result) {
          return const Right(true);
        }
        return const Left(ApiFailure(message: 'Invalid or expired OTP'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Invalid or expired OTP',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    return const Left(
      NetworkFailure(message: 'Internet connection required to verify OTP'),
    );
  }

  @override
  Future<Either<Failure, bool>> resetPasswordWithOTP(
    String email,
    String otp,
    String password,
    String confirmPassword,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.resetPasswordWithOTP(
          email,
          otp,
          password,
          confirmPassword,
        );
        if (result) {
          return const Right(true);
        }
        return const Left(ApiFailure(message: 'Failed to reset password'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to reset password',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    return const Left(
      NetworkFailure(message: 'Internet connection required to reset password'),
    );
  }
}

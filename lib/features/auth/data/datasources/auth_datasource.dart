import 'package:tripmates/features/auth/data/models/auth_api_model.dart';
import 'package:tripmates/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<AuthHiveModel?> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(String authId);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String authId);
  Future<bool> forgotPassword(String email, {String? platform});
  Future<bool> verifyOTP(String email, String otp);
  Future<bool> resetPassword(
    String token,
    String password,
    String confirmPassword,
  );
  Future<bool> resetPasswordWithOTP(
    String email,
    String otp,
    String password,
    String confirmPassword,
  );
}

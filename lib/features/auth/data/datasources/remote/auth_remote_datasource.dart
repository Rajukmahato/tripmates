import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/core/services/hive/hive_service.dart';
import 'package:tripmates/core/services/storage/token_service.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/features/auth/data/datasources/auth_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tripmates/features/auth/data/models/auth_api_model.dart';
import 'package:tripmates/features/auth/data/models/auth_hive_model.dart';
import 'package:tripmates/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:tripmates/features/profile/data/repositories/profile_repository.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';

// Create provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
    hiveService: ref.read(hiveServiceProvider),
    profileLocalDataSource: ref.read(profileLocalDataSourceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;
  final HiveService _hiveService;
  final IProfileLocalDataSource _profileLocalDataSource;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
    required HiveService hiveService,
    required IProfileLocalDataSource profileLocalDataSource,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService,
       _hiveService = hiveService,
       _profileLocalDataSource = profileLocalDataSource;

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    final response = await _apiClient.get(ApiEndpoints.userProfile(authId));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);
      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // Save complete user session to SharedPreferences
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
        phoneNumber: user.phoneNumber,
        batchId: user.batchId,
        profilePicture: user.profilePicture,
        bio: user.bio,
        location: user.location,
        role: user.role,
        totalTrips: user.totalTrips,
        completedTrips: user.completedTrips,
      );

      // Save user to Hive for offline access
      final hiveModel = AuthHiveModel(
        authId: user.id,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        username: user.username,
        // Cache password for explicit offline credential validation.
        password: password,
        batchId: user.batchId,
        profilePicture: user.profilePicture,
      );
      await _hiveService.register(hiveModel);

      // Also cache user profile for offline profile viewing
      await _profileLocalDataSource.cacheProfile(
        ProfileEntity(
          userId: user.id,
          fullName: user.fullName,
          email: user.email,
          phone: user.phoneNumber,
          profilePicture: user.profilePicture,
          bio: user.bio,
          location: user.location,
          totalTrips: user.totalTrips ?? 0,
          completedTrips: user.completedTrips ?? 0,
        ),
      );

      // Save token to TokenService (SharedPreferences)
      final token = response.data['token'];
      await _tokenService.saveToken(token);
      // Also write token to FlutterSecureStorage so ApiClient interceptor can read it
      await const FlutterSecureStorage().write(key: 'auth_token', value: token);
      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRegister,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }

  @override
  Future<bool> forgotPassword(String email, {String? platform}) async {
    try {
      print('🔐 [AuthRemoteDatasource] forgotPassword called');
      print('   Email: $email');
      print('   Platform: $platform');

      final data = {'email': email, if (platform != null) 'platform': platform};
      print('   Sending data to backend: $data');

      final response = await _apiClient.post(
        ApiEndpoints.authForgotPassword,
        data: data,
      );

      print('✅ [AuthRemoteDatasource] Response: ${response.data}');
      return response.data['success'] == true;
    } catch (e) {
      print('❌ [AuthRemoteDatasource] Exception: $e');
      return false;
    }
  }

  @override
  Future<bool> resetPassword(
    String token,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authResetPassword,
        data: {
          'token': token,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      print('🔐 [AuthRemoteDatasource] verifyOTP called');
      print('   Email: $email');
      print('   OTP: $otp');

      final response = await _apiClient.post(
        ApiEndpoints.authVerifyOTP,
        data: {'email': email, 'otp': otp},
      );

      print('✅ [AuthRemoteDatasource] Verify OTP Response: ${response.data}');
      return response.data['success'] == true;
    } catch (e) {
      print('❌ [AuthRemoteDatasource] Verify OTP Exception: $e');
      return false;
    }
  }

  @override
  Future<bool> resetPasswordWithOTP(
    String email,
    String otp,
    String password,
    String confirmPassword,
  ) async {
    try {
      print('🔐 [AuthRemoteDatasource] resetPasswordWithOTP called');
      print('   Email: $email');

      final response = await _apiClient.post(
        ApiEndpoints.authResetPasswordOTP,
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      print(
        '✅ [AuthRemoteDatasource] Reset Password with OTP Response: ${response.data}',
      );
      return response.data['success'] == true;
    } catch (e) {
      print('❌ [AuthRemoteDatasource] Reset Password with OTP Exception: $e');
      return false;
    }
  }
}

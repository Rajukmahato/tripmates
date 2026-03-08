import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/core/services/hive/hive_service.dart';
import 'package:tripmates/core/services/storage/token_service.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/features/auth/data/datasources/auth_datasource.dart';
import 'package:tripmates/features/auth/data/models/auth_hive_model.dart';
import 'package:tripmates/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:tripmates/features/profile/data/repositories/profile_repository.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';

// Create provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  final tokenService = ref.read(tokenServiceProvider);
  final profileLocalDataSource = ref.read(profileLocalDataSourceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
    tokenService: tokenService,
    profileLocalDataSource: profileLocalDataSource,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;
  final IProfileLocalDataSource _profileLocalDataSource;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
    required TokenService tokenService,
    required IProfileLocalDataSource profileLocalDataSource,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService,
       _tokenService = tokenService,
       _profileLocalDataSource = profileLocalDataSource;

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    return await _hiveService.register(user);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = _hiveService.login(email, password);
      if (user != null && user.authId != null) {
        // Save user session to SharedPreferences
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          username: user.username,
          phoneNumber: user.phoneNumber,
          batchId: user.batchId,
          profilePicture: user.profilePicture,
        );

        // Also ensure profile is cached for offline profile viewing
        await _profileLocalDataSource.cacheProfile(
          ProfileEntity(
            userId: user.authId,
            fullName: user.fullName,
            email: user.email,
            phone: user.phoneNumber,
            profilePicture: user.profilePicture,
          ),
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      // Check if user is logged in
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }

      // Get user ID from session
      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) {
        return null;
      }

      // Fetch user from Hive database
      return _hiveService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // Clear user session from SharedPreferences
      await _userSessionService.clearSession();
      // Clear token from both SharedPreferences and FlutterSecureStorage
      await _tokenService.removeToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    try {
      return _hiveService.getUserById(authId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      return await _hiveService.updateUser(user);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

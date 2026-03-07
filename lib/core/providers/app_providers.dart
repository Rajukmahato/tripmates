import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/services/connectivity/network_info.dart';
import 'package:tripmates/core/services/hive/hive_service.dart';
import 'package:tripmates/core/services/storage/token_service.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/core/services/time/server_time_service.dart';
import 'package:tripmates/core/providers/shared_prefs_provider.dart';

// ============================= SHARED PREFERENCES PROVIDER =============================
/// Export the sharedPreferencesProvider and storageServiceProvider from shared_prefs_provider.dart
export 'package:tripmates/core/providers/shared_prefs_provider.dart'
    show sharedPreferencesProvider, storageServiceProvider;

// ============================= DIO API CLIENT PROVIDER =============================
/// Provides the Dio HTTP client instance configured with base URL, interceptors, and timeouts
final dioClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// ============================= HIVE SERVICE PROVIDER =============================
/// Provides the Hive local database service for caching
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

// ============================= TOKEN SERVICE PROVIDER =============================
/// Provides the secure token service for JWT token management
final tokenServiceProvider = Provider<TokenService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return TokenService(sharedPreferences);
});

// ============================= USER SESSION SERVICE PROVIDER =============================
/// Provides user session management
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return UserSessionService(sharedPreferences);
});

// ============================= CONNECTIVITY PROVIDER =============================
/// Provides network connectivity status
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

// ============================= SERVER TIME SERVICE PROVIDER =============================
/// Provides server time synchronization service for accurate trip status checking
final serverTimeServiceProvider = Provider<ServerTimeService>((ref) {
  return ServerTimeService();
});

// ============================= CONNECTIVITY STATUS FUTURE PROVIDER =============================
/// Watches network connectivity status
final connectivityStatusProvider = FutureProvider<bool>((ref) async {
  final networkInfo = ref.watch(networkInfoProvider);
  return await networkInfo.isConnected;
});

// ============================= CURRENT USER TOKEN PROVIDER =============================
/// Provides the current user's JWT token
final currentTokenProvider = FutureProvider<String?>((ref) async {
  final tokenService = ref.watch(tokenServiceProvider);
  return await tokenService.getToken();
});

// ============================= CURRENT USER SESSION PROVIDER =============================
/// Provides the current user session information
final currentUserSessionProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final sessionService = ref.watch(userSessionServiceProvider);
  final userId = sessionService.getUserId();
  if (userId == null) return null;

  return {
    'userId': userId,
    'email': sessionService.getUserEmail(),
    'fullName': sessionService.getUserFullName(),
    'username': sessionService.getUserUsername(),
    'phoneNumber': sessionService.getUserPhoneNumber(),
    'profilePicture': sessionService.getUserProfilePicture(),
  };
});

// ============================= IS AUTHENTICATED PROVIDER =============================
/// Provides whether the user is currently authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final token = await ref.watch(currentTokenProvider.future);
  return token != null && token.isNotEmpty;
});

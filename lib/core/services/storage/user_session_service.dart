import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserUsername = 'user_username';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyUserBatchId = 'user_batch_id';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyUserBio = 'user_bio';
  static const String _keyUserLocation = 'user_location';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserTotalTrips = 'user_total_trips';
  static const String _keyUserCompletedTrips = 'user_completed_trips';

  UserSessionService(SharedPreferences prefs) : _prefs = prefs;

  // Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    required String username,
    String? phoneNumber,
    String? batchId,
    String? profilePicture,
    String? bio,
    String? location,
    String? role,
    int? totalTrips,
    int? completedTrips,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUserUsername, username);
    if (phoneNumber != null) {
      await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    }
    if (batchId != null) {
      await _prefs.setString(_keyUserBatchId, batchId);
    }
    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
    if (bio != null) {
      await _prefs.setString(_keyUserBio, bio);
    }
    if (location != null) {
      await _prefs.setString(_keyUserLocation, location);
    }
    if (role != null) {
      await _prefs.setString(_keyUserRole, role);
    }
    if (totalTrips != null) {
      await _prefs.setInt(_keyUserTotalTrips, totalTrips);
    }
    if (completedTrips != null) {
      await _prefs.setInt(_keyUserCompletedTrips, completedTrips);
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Get current user full name
  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  // Get current user username
  String? getCurrentUserUsername() {
    return _prefs.getString(_keyUserUsername);
  }

  // Get current user phone number
  String? getCurrentUserPhoneNumber() {
    return _prefs.getString(_keyUserPhoneNumber);
  }

  // Get current user batch ID
  String? getCurrentUserBatchId() {
    return _prefs.getString(_keyUserBatchId);
  }

  // Get current user profile picture
  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }

  // Get current user bio
  String? getCurrentUserBio() {
    return _prefs.getString(_keyUserBio);
  }

  // Get current user location
  String? getCurrentUserLocation() {
    return _prefs.getString(_keyUserLocation);
  }

  // Get current user role
  String? getCurrentUserRole() {
    return _prefs.getString(_keyUserRole);
  }

  // Get current user total trips
  int? getCurrentUserTotalTrips() {
    return _prefs.getInt(_keyUserTotalTrips);
  }

  // Get current user completed trips
  int? getCurrentUserCompletedTrips() {
    return _prefs.getInt(_keyUserCompletedTrips);
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserUsername);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyUserBatchId);
    await _prefs.remove(_keyUserProfilePicture);
    await _prefs.remove(_keyUserBio);
    await _prefs.remove(_keyUserLocation);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserTotalTrips);
    await _prefs.remove(_keyUserCompletedTrips);

    // Also remove token from FlutterSecureStorage
    await _secureStorage.delete(key: 'auth_token');
  }

  /// Alias methods for app_providers.dart compatibility
  String? getUserId() => getCurrentUserId();
  String? getUserEmail() => getCurrentUserEmail();
  String? getUserFullName() => getCurrentUserFullName();
  String? getUserUsername() => getCurrentUserUsername();
  String? getUserPhoneNumber() => getCurrentUserPhoneNumber();
  String? getUserProfilePicture() => getCurrentUserProfilePicture();
  String? getUserBio() => getCurrentUserBio();
  String? getUserLocation() => getCurrentUserLocation();
  String? getUserRole() => getCurrentUserRole();
  int? getUserTotalTrips() => getCurrentUserTotalTrips();
  int? getUserCompletedTrips() => getCurrentUserCompletedTrips();
}

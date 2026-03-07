import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const String _envApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const bool isPhysicalDevice = bool.fromEnvironment(
    'IS_PHYSICAL_DEVICE',
    defaultValue: false,
  );

  static const String compIpAddress = "192.168.1.1";

  // Backend port - Backend API running on port 5050
  static const int backendPort = 5050;

  static String get baseUrl {
    if (_envApiBaseUrl.isNotEmpty) {
      return _envApiBaseUrl.endsWith('/api')
          ? _envApiBaseUrl
          : '$_envApiBaseUrl/api';
    }

    if (isPhysicalDevice) {
      return 'http://$compIpAddress:$backendPort/api';
    }

    // Android emulator cannot access host machine via localhost.
    if (kIsWeb) {
      return 'http://localhost:$backendPort/api';
    } else if (Platform.isAndroid) {
      // return 'http://10.0.2.2:$backendPort/api';
      // using the adb reverse so the localhost will work.
      return 'http://localhost:$backendPort/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:$backendPort/api';
    } else {
      return 'http://localhost:$backendPort/api';
    }
  }

  // Origin without the /api suffix, useful for constructing absolute file URLs
  static String get baseOrigin {
    final uri = Uri.parse(baseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Health Check ============
  static const String healthCheck = '/';

  // ============ Authentication Endpoints (/api/auth) ============
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyOTP = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';
  static const String authResetPasswordOTP = '/auth/reset-password-otp';
  static String authUpdateProfile(String userId) => '/auth/$userId';

  // ============ User Profile Endpoints (/api/user) ============
  static String userProfile(String userId) => '/user/profile/$userId';
  static String updateUserProfile(String userId) => '/user/profile/$userId';

  // ============ Trip Endpoints (/api/trips) ============
  static const String trips = '/trips';
  static const String tripsSearch = '/trips/search';
  static String tripsByUser(String userId) => '/trips/user/$userId';
  static String tripById(String id) => '/trips/$id';

  // Trip Itinerary Routes (v2)
  static String tripItinerary(String tripId) => '/trips/$tripId/itinerary';

  // Trip Checklist Routes (v2)
  static String tripChecklist(String tripId) => '/trips/$tripId/checklist';

  // ============ Partner Request Endpoints (/api/partner-requests) ============
  static const String partnerRequests = '/partner-requests';
  static const String partnerRequestsSend = '/partner-requests';
  static const String partnerRequestsReceived = '/partner-requests/received';
  static const String partnerRequestsSent = '/partner-requests/sent';
  static String partnerRequestById(String id) => '/partner-requests/$id';
  static String partnerRequestAccept(String id) =>
      '/partner-requests/$id/status';
  static String partnerRequestReject(String id) =>
      '/partner-requests/$id/status';
  static String partnerRequestStatus(String id) =>
      '/partner-requests/$id/status';
  // Pending count endpoint is not available in v2 backend; derive from
  // GET /partner-requests/received?status=pending.
  static const String partnerRequestsPendingCount =
      '/partner-requests/received';

  // ============ Chat Endpoints (/api/chat) ============
  // Private Chat
  static const String chatConversations = '/chat/conversations';
  static String chatMessages(String userId) => '/chat/messages/$userId';
  static const String chatSendMessage = '/chat/messages';
  static String chatMarkAsRead(String userId) => '/chat/messages/$userId/read';
  static const String chatUnreadCount = '/chat/unread-count';

  // Group Chat (v2)
  static const String chatGroups = '/chat/groups';
  static String chatGroupByTripId(String tripId) => '/chat/groups/$tripId';
  static String chatGroupByGroupId(String groupChatId) =>
      '/chat/groups/chat/$groupChatId';
  static String chatGroupMembers(String groupId) =>
      '/chat/groups/$groupId/members';
  static String chatGroupMessages(String groupId) =>
      '/chat/groups/$groupId/messages';

  // ============ Notification Endpoints (/api/notifications) ============
  static const String notificationRegisterToken =
      '/notifications/register-token';
  static const String notifications = '/notifications';
  static const String notificationUnreadCount = '/notifications/unread-count';
  static const String notificationReadAll = '/notifications/read-all';
  static String notificationMarkAsRead(String id) => '/notifications/$id/read';

  // ============ Review Endpoints (/api/reviews) ============
  static const String reviews = '/reviews';
  static String reviewsByUser(String userId) => '/reviews/user/$userId';
  static const String myReviews = '/reviews/my';
  static const String adminAllReviews = '/reviews/admin/all';
  static String deleteReview(String id) => '/reviews/admin/$id';

  // ============ Report Endpoints (/api/reports) ============
  static const String reports = '/reports';
  static const String adminReportStats = '/reports/admin/stats';
  static const String adminAllReports = '/reports/admin/all';
  static String adminReportById(String id) => '/reports/admin/$id';
  static String adminReportsByUser(String userId) =>
      '/reports/admin/user/$userId';
  static String adminReportReview(String id) => '/reports/admin/$id/review';
  static String adminReportResolve(String id) => '/reports/admin/$id/resolve';

  // ============ Admin Endpoints (/api/admin) ============
  // User Management
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';

  // Trip Management
  static const String adminTrips = '/admin/trips';
  static String adminTripById(String id) => '/admin/trips/$id';

  // Analytics (v2)
  static const String adminAnalyticsOverview = '/admin/analytics/overview';
  static const String adminAnalyticsUsers = '/admin/analytics/users';
  static const String adminAnalyticsTrips = '/admin/analytics/trips';
  static const String adminAnalyticsMatches = '/admin/analytics/matches';
  static const String adminAnalyticsPerformance =
      '/admin/analytics/performance';

  // ============ Destination Endpoints (/api/destinations) - v2 ============
  static const String destinations = '/destinations';
  static const String destinationsSearch = '/destinations/search';
  static String destinationById(String id) => '/destinations/$id';
  static const String adminDestinations = '/destinations/admin/stats';

  // ============ Location Endpoints (/api/location) - v2 ============
  static const String locationShare = '/location/share';
  static const String locationUpdate = '/location/update';
  static const String locationStop = '/location/stop';
  static String locationByTrip(String tripId) => '/location/trip/$tripId';
  static const String locationNearby = '/location/nearby';
  static const String locationRoute = '/location/route';

  // ============ Legacy/Deprecated Endpoints (for backward compatibility) ============
  // Categories - Legacy endpoint, not part of TripMates core
  static const String categories =
      '/categories'; // DEPRECATED: Use trip categories instead
  static const String updateProfile =
      '/auth'; // Maps to auth update profile endpoint
}

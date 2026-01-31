import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.1.1";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api';
    }
    // yadi android
    if (kIsWeb) {
      return 'http://localhost:5050/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api';
    } else {
      return 'http://localhost:5050/api';
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

  // ============ Auth Endpoints ============
  static const String auth = '/auth';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';

  // ============ Batch Endpoints ============
  static const String batches = '/batches';
  static String batchById(String id) => '/batches/$id';

  // ============ Category Endpoints ============
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Student Endpoints ============
  static const String students = '/students';
  static const String studentLogin = '/students/login';
  static const String studentRegister = '/students/register';
  static String studentById(String id) => '/students/$id';
  static String studentPhoto(String id) => '/students/$id/photo';

  // ============ Item Endpoints ============
  static const String items = '/items';
  static String itemById(String id) => '/items/$id';
  static String itemClaim(String id) => '/items/$id/claim';
  static const String itemUploadPhoto = '/items/upload-photo';
  static const String itemUploadVideo = '/items/upload-video';

  // ============ Comment Endpoints ============
  static const String comments = '/comments';
  static String commentById(String id) => '/comments/$id';
  static String commentsByItem(String itemId) => '/comments/item/$itemId';
  static String commentLike(String id) => '/comments/$id/like';

  // ============ Profile Endpoints ============
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
}

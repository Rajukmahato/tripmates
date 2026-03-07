import 'dart:io';
import 'package:flutter/foundation.dart';

enum AppPlatform { android, ios, web }

class PlatformUtil {
  static AppPlatform getCurrentPlatform() {
    if (kIsWeb) {
      return AppPlatform.web;
    } else if (Platform.isAndroid) {
      return AppPlatform.android;
    } else if (Platform.isIOS) {
      return AppPlatform.ios;
    }
    // Default fallback
    return AppPlatform.web;
  }

  static String getPlatformString() {
    return getCurrentPlatform().name; // 'android', 'ios', or 'web'
  }

  static bool get isAndroid => getCurrentPlatform() == AppPlatform.android;
  static bool get isIOS => getCurrentPlatform() == AppPlatform.ios;
  static bool get isWeb => getCurrentPlatform() == AppPlatform.web;
  static bool get isMobile => isAndroid || isIOS;
}

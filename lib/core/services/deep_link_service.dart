import 'dart:async';
import 'package:flutter/services.dart';

class DeepLinkHandler {
  static const _channel = MethodChannel('com.raju.tripmates/deeplink');
  static StreamController<String>? _deepLinkController;

  static Stream<String> get deepLinkStream {
    _deepLinkController ??= StreamController<String>.broadcast(
      onListen: () {
        _getInitialLink();
        _setupDeepLinkListener();
      },
    );
    return _deepLinkController!.stream;
  }

  static Future<void> _getInitialLink() async {
    try {
      final link = await _channel.invokeMethod<String>('getInitialLink');
      if (link != null && link.isNotEmpty) {
        _deepLinkController?.add(link);
      }
    } catch (e) {
      print('Error getting initial deep link: $e');
    }
  }

  static void _setupDeepLinkListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final link = call.arguments as String?;
        if (link != null && link.isNotEmpty) {
          _deepLinkController?.add(link);
        }
      }
    });
  }

  static void dispose() {
    _deepLinkController?.close();
    _deepLinkController = null;
  }

  /// Parse deep link URI and return token if it's a reset password link
  /// Expected format: tripmates://reset-password/?token=<reset_token>
  static String? extractResetToken(String deepLink) {
    try {
      final uri = Uri.parse(deepLink);

      // Check if it's a reset password deep link
      if (uri.scheme == 'tripmates' && uri.host == 'reset-password') {
        return uri.queryParameters['token'];
      }

      return null;
    } catch (e) {
      print('Error parsing deep link: $e');
      return null;
    }
  }
}

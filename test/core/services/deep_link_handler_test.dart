import 'package:flutter_test/flutter_test.dart';
import 'package:tripmates/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkHandler', () {
    test('should extract reset token from valid deep link', () {
      const validDeepLink = 'tripmates://reset-password/?token=abc123xyz';

      final token = DeepLinkHandler.extractResetToken(validDeepLink);

      expect(token, equals('abc123xyz'));
    });

    test('should extract token with multiple query parameters', () {
      const deepLink =
          'tripmates://reset-password/?token=reset_token_123&email=test@example.com';

      final token = DeepLinkHandler.extractResetToken(deepLink);

      expect(token, equals('reset_token_123'));
    });

    test('should return null for non-reset-password deep link', () {
      const invalidDeepLink = 'tripmates://other-screen/?data=value';

      final token = DeepLinkHandler.extractResetToken(invalidDeepLink);

      expect(token, isNull);
    });

    test('should return null when token parameter is missing', () {
      const deepLink = 'tripmates://reset-password/?email=test@example.com';

      final token = DeepLinkHandler.extractResetToken(deepLink);

      expect(token, isNull);
    });

    test('should handle malformed URIs gracefully', () {
      const malformedDeepLink = 'not a valid uri';

      final token = DeepLinkHandler.extractResetToken(malformedDeepLink);

      expect(token, isNull);
    });
  });
}

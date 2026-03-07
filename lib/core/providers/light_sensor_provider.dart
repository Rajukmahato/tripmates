import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/theme_provider.dart';
import 'package:tripmates/core/services/light_sensor_service.dart';
import 'package:tripmates/core/providers/shared_prefs_provider.dart';

/// Provider for automatic theme switching preference
final autoThemeSwitchProvider = NotifierProvider<AutoThemeSwitchNotifier, bool>(
  AutoThemeSwitchNotifier.new,
);

/// Provider for shake-to-logout preference
final shakeToLogoutSwitchProvider =
    NotifierProvider<ShakeToLogoutSwitchNotifier, bool>(
      ShakeToLogoutSwitchNotifier.new,
    );

class AutoThemeSwitchNotifier extends Notifier<bool> {
  static const String _autoThemeKey = 'auto_theme_switch';

  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_autoThemeKey) ?? true; // Enabled by default
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = enabled;
    await prefs.setBool(_autoThemeKey, enabled);
  }
}

class ShakeToLogoutSwitchNotifier extends Notifier<bool> {
  static const String _shakeToLogoutKey = 'shake_to_logout_switch';

  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_shakeToLogoutKey) ?? true; // Enabled by default
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = enabled;
    await prefs.setBool(_shakeToLogoutKey, enabled);
  }
}

/// Provider for light sensor service
final lightSensorServiceProvider = Provider<LightSensorService?>((ref) {
  // Only create service if auto theme is enabled
  final autoThemeEnabled = ref.watch(autoThemeSwitchProvider);
  if (!autoThemeEnabled) return null;

  final service = LightSensorService(
    onThemeChange: (shouldBeDark) {
      // Update theme based on light sensor
      final currentTheme = ref.read(themeModeProvider);
      final newTheme = shouldBeDark ? ThemeMode.dark : ThemeMode.light;

      debugPrint(
        '🎨 Light sensor callback: shouldBeDark=$shouldBeDark, currentTheme=$currentTheme, newTheme=$newTheme',
      );

      // Always change theme when auto-theme is enabled, regardless of current mode
      if (currentTheme != newTheme) {
        debugPrint('🎨 Changing theme to: $newTheme');
        ref.read(themeModeProvider.notifier).setThemeMode(newTheme);
      } else {
        debugPrint('🎨 Theme already set to: $newTheme');
      }
    },
    lightThreshold: 200, // 200 lux threshold
    debounceDuration: const Duration(seconds: 3),
  );

  // Start listening
  service.startListening();

  // Cleanup on dispose
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

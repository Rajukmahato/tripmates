import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:light/light.dart';

/// Service to monitor ambient light and provide smart theme switching recommendations
class LightSensorService {
  /// Callback when theme should change based on light level
  final ValueChanged<bool> onThemeChange;

  /// Light threshold in lux (below = dark theme, above = light theme)
  /// Typical values: Indoor dim light: 100-200 lux, Bright indoor: 300-500 lux,
  /// Outdoor shade: 1000+ lux, Direct sunlight: 10000+ lux
  final int lightThreshold;

  /// Debounce duration to avoid rapid theme changes
  final Duration debounceDuration;

  Light? _light;
  StreamSubscription<int>? _subscription;
  Timer? _debounceTimer;
  bool? _lastCalculatedShouldBeDark; // Track last CALCULATED value

  LightSensorService({
    required this.onThemeChange,
    this.lightThreshold = 200, // 200 lux threshold (dim indoor light)
    this.debounceDuration = const Duration(seconds: 3),
  });

  /// Start listening to light sensor
  Future<void> startListening() async {
    try {
      _light = Light();
      _subscription = _light?.lightSensorStream.listen(_onLightDataReceived);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Light sensor not available: $e');
      }
    }
  }

  void _onLightDataReceived(int luxValue) {
    // Determine if theme should be dark based on light level
    final shouldBeDark = luxValue < lightThreshold;

    if (kDebugMode) {
      print(
        '💡 LightSensorService: Received $luxValue lux → shouldBeDark=$shouldBeDark, lastCalculated=$_lastCalculatedShouldBeDark',
      );
    }

    // Only trigger change if CALCULATED value has changed (not on every fluctuation)
    if (_lastCalculatedShouldBeDark != shouldBeDark) {
      // Cancel existing debounce timer
      _debounceTimer?.cancel();

      // Update what we calculated (for next comparison)
      _lastCalculatedShouldBeDark = shouldBeDark;

      if (kDebugMode) {
        print(
          '💡 LightSensorService: Calculated theme CHANGED to ${shouldBeDark ? 'dark' : 'light'}, starting ${debounceDuration.inSeconds}s debounce timer...',
        );
      }

      // Start new debounce timer
      _debounceTimer = Timer(debounceDuration, () {
        if (kDebugMode) {
          print(
            '💡 LightSensorService: Debounce complete! Applying ${shouldBeDark ? 'Dark' : 'Light'} theme (from $luxValue lux)',
          );
        }

        onThemeChange(shouldBeDark);
      });
    }
  }

  /// Stop listening to light sensor
  void stopListening() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _light = null;
    _lastCalculatedShouldBeDark = null;
  }

  /// Clean up resources
  void dispose() {
    stopListening();
  }
}

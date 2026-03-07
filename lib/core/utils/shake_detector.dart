import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Shake detector utility to detect phone shake gestures
class ShakeDetector {
  /// Callback when shake is detected
  final VoidCallback onShake;

  /// Minimum force required to consider it a shake
  final double shakeThreshold;

  /// Time window to consider consecutive shakes
  final Duration shakeDuration;

  /// Number of shakes required to trigger callback
  final int shakeCount;

  StreamSubscription<AccelerometerEvent>? _streamSubscription;
  int _shakeCounter = 0;
  DateTime? _lastShakeTime;
  Timer? _resetTimer;

  ShakeDetector({
    required this.onShake,
    this.shakeThreshold = 15.0,
    this.shakeDuration = const Duration(milliseconds: 1500),
    this.shakeCount = 2,
  });

  /// Start listening to accelerometer events
  void startListening() {
    _streamSubscription = accelerometerEventStream().listen((event) {
      final gForce = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Check if force exceeds threshold (indicating a shake)
      if (gForce > shakeThreshold) {
        final now = DateTime.now();

        // Check if this shake is within the time window of the last shake
        if (_lastShakeTime != null &&
            now.difference(_lastShakeTime!) < shakeDuration) {
          _shakeCounter++;
        } else {
          // Reset counter if too much time has passed
          _shakeCounter = 1;
        }

        _lastShakeTime = now;

        // If reached required shake count, trigger callback
        if (_shakeCounter >= shakeCount) {
          _shakeCounter = 0;
          _lastShakeTime = null;
          onShake();
        }

        // Reset counter after duration
        _resetTimer?.cancel();
        _resetTimer = Timer(shakeDuration, () {
          _shakeCounter = 0;
          _lastShakeTime = null;
        });
      }
    });
  }

  /// Stop listening to accelerometer events
  void stopListening() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _resetTimer?.cancel();
    _resetTimer = null;
    _shakeCounter = 0;
    _lastShakeTime = null;
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tripmates/features/location/domain/entities/location_entity.dart';

/// Provider for LocationService singleton instance
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Service to manage location permissions and GPS positioning
class LocationService {
  LocationService();

  /// Check if location permissions are granted
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      log('Error checking location permission: $e');
      return false;
    }
  }

  /// Request location permissions
  /// Returns true if granted, false if denied/restricted/permanently denied
  Future<bool> requestPermission() async {
    try {
      // Check if already granted
      final status = await Permission.location.status;
      if (status.isGranted) {
        return true;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled');
        return false;
      }

      // Request permission
      final requestResult = await Permission.location.request();

      if (requestResult.isGranted) {
        log('Location permission granted');
        return true;
      } else if (requestResult.isPermanentlyDenied) {
        log(
          'Location permission permanently denied. User must enable in settings.',
        );
        // Could show dialog to open app settings
        // await openAppSettings();
        return false;
      } else {
        log('Location permission denied: $requestResult');
        return false;
      }
    } catch (e) {
      log('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current location once
  /// Throws exception if permission denied or location unavailable
  Future<Position> getCurrentLocation() async {
    try {
      // Request permission if not granted
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) {
          throw Exception('Location permission denied');
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log(
        'Current location: ${position.latitude}, ${position.longitude}, accuracy: ${position.accuracy}m',
      );
      return position;
    } catch (e) {
      log('Error getting current location: $e');
      rethrow;
    }
  }

  /// Get a stream of location updates for continuous tracking
  ///
  /// [accuracyLevel] - LocationAccuracy enum (high, medium, low, lowest)
  /// [distanceFilter] - Minimum distance (meters) before update triggered (default: 10m)
  ///
  /// Returns `Stream<Position>` that emits location updates
  Stream<Position> getLocationStream({
    LocationAccuracy accuracyLevel = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    try {
      final locationSettings = LocationSettings(
        accuracy: accuracyLevel,
        distanceFilter: distanceFilter,
      );

      return Geolocator.getPositionStream(locationSettings: locationSettings);
    } catch (e) {
      log('Error starting location stream: $e');
      rethrow;
    }
  }

  /// Convert Position to LocationEntity
  /// Requires userId, userName, tripId from caller context
  LocationEntity positionToEntity({
    required Position position,
    required String userId,
    required String userName,
    required String tripId,
  }) {
    return LocationEntity(
      id: '', // Will be assigned by backend
      userId: userId,
      userName: userName,
      tripId: tripId,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      accuracy: position.accuracy,
    );
  }

  /// Check if location services are enabled on device
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      log('Error checking location service status: $e');
      return false;
    }
  }

  /// Get last known position (faster but may be stale)
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      log('Error getting last known position: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates in meters
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two coordinates in degrees
  double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open app settings (useful when permission permanently denied)
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      log('Error opening app settings: $e');
      return false;
    }
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      log('Error opening location settings: $e');
      return false;
    }
  }
}

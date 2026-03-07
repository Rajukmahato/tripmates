import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tripmates/core/services/location/location_service.dart';
import 'package:tripmates/core/services/socket/socket_service.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/features/location/data/models/location_api_model.dart';
import 'package:tripmates/features/location/data/repositories/location_repository_impl.dart';
import 'package:tripmates/features/location/domain/repositories/location_repository.dart';
import 'package:tripmates/features/location/presentation/state/location_state.dart';

/// Provider for location viewmodel
final locationViewModelProvider =
    NotifierProvider<LocationViewModel, LocationState>(() {
      return LocationViewModel();
    });

/// ViewModel for location sharing feature
class LocationViewModel extends Notifier<LocationState> {
  late final LocationService _locationService;
  late final ILocationRepository _locationRepository;
  late final SocketService _socketService;
  late final UserSessionService _sessionService;

  StreamSubscription<Position>? _locationStreamSubscription;

  @override
  LocationState build() {
    _locationService = ref.read(locationServiceProvider);
    _locationRepository = ref.read(locationRepositoryProvider);
    _socketService = ref.read(socketServiceProvider);
    _sessionService = ref.read(userSessionServiceProvider);

    // Set up socket listeners for incoming location updates
    _setupSocketListeners();

    // Check initial permission state
    _checkInitialPermission();

    return const LocationState();
  }

  /// Check initial permission state
  Future<void> _checkInitialPermission() async {
    final hasPermission = await _locationService.hasPermission();
    state = state.copyWith(hasPermission: hasPermission);
  }

  /// Set up socket event listeners for location updates from other members
  void _setupSocketListeners() {
    // Listen for location updates from other trip members
    _socketService.onLocationUpdate((data) {
      _handleIncomingLocationUpdate(data);
    });

    // Listen for location sharing start
    _socketService.onLocationStart((data) {
      _handleIncomingLocationUpdate(data);
    });

    // Listen for location sharing stop
    _socketService.onLocationStop((data) {
      final userId = data['userId'] as String?;
      if (userId != null) {
        _removeUserLocation(userId);
      }
    });
  }

  /// Handle incoming location update from socket
  void _handleIncomingLocationUpdate(Map<String, dynamic> data) {
    try {
      final locationModel = LocationApiModel.fromJson(data);
      final locationEntity = locationModel.toEntity();

      // Don't update if it's current user's own location (already handled locally)
      final currentUserId = _sessionService.getUserId();
      if (locationEntity.userId == currentUserId) return;

      // Update or add location to list
      final updatedLocations = [...state.locations];
      final existingIndex = updatedLocations.indexWhere(
        (loc) => loc.userId == locationEntity.userId,
      );

      if (existingIndex != -1) {
        updatedLocations[existingIndex] = locationEntity;
      } else {
        updatedLocations.add(locationEntity);
      }

      state = state.copyWith(
        locations: updatedLocations,
        lastLocationUpdate: DateTime.now(),
      );

      log('Updated location for user ${locationEntity.userName}');
    } catch (e) {
      log('Error handling incoming location: $e');
    }
  }

  /// Remove user location when they stop sharing
  void _removeUserLocation(String userId) {
    final updatedLocations = state.locations
        .where((loc) => loc.userId != userId)
        .toList();

    state = state.copyWith(locations: updatedLocations);
    log('Removed location for user $userId');
  }

  /// Check if location permission is granted
  Future<bool> checkPermission() async {
    final hasPermission = await _locationService.hasPermission();
    state = state.copyWith(hasPermission: hasPermission);
    return hasPermission;
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    final granted = await _locationService.requestPermission();
    state = state.copyWith(hasPermission: granted);

    if (!granted) {
      state = state.copyWith(
        error: 'Location permission denied. Please enable it in settings.',
      );
    }

    return granted;
  }

  /// Start location sharing for a trip
  Future<void> startSharing(String tripId) async {
    if (state.isStarting || state.isSharing) return;

    state = state.copyWith(isStarting: true, error: null);

    try {
      // Check permission
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) {
          state = state.copyWith(isStarting: false);
          return;
        }
      }

      // Get current location first
      final position = await _locationService.getCurrentLocation();

      final userId = _sessionService.getUserId();
      final userName = _sessionService.getUserFullName();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Call API to start location sharing
      final result = await _locationRepository.startLocationSharing(
        tripId: tripId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      result.fold(
        (failure) {
          state = state.copyWith(isStarting: false, error: failure.message);
        },
        (_) async {
          // Create location entity for current user
          final locationEntity = _locationService.positionToEntity(
            position: position,
            userId: userId,
            userName: userName ?? 'Unknown',
            tripId: tripId,
          );

          // Emit socket event
          _socketService.emitStartLocationSharing(
            tripId: tripId,
            latitude: position.latitude,
            longitude: position.longitude,
          );

          // Join trip's location room
          _socketService.joinTripLocationRoom(tripId);

          // Start location stream
          _startLocationStream(tripId, userId, userName ?? 'Unknown');

          state = state.copyWith(
            isSharing: true,
            isStarting: false,
            currentTripId: tripId,
            currentUserLocation: locationEntity,
            lastLocationUpdate: DateTime.now(),
          );

          log('Started location sharing for trip $tripId');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isStarting: false,
        error: 'Failed to start location sharing: $e',
      );
      log('Error starting location sharing: $e');
    }
  }

  /// Start location stream for continuous updates
  void _startLocationStream(String tripId, String userId, String userName) {
    _locationStreamSubscription?.cancel();

    _locationStreamSubscription = _locationService
        .getLocationStream(
          accuracyLevel: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        )
        .listen(
          (position) {
            _handleLocationUpdate(position, tripId, userId, userName);
          },
          onError: (error) {
            log('Location stream error: $error');
            state = state.copyWith(error: 'Location tracking error: $error');
          },
        );
  }

  /// Handle location update from stream
  Future<void> _handleLocationUpdate(
    Position position,
    String tripId,
    String userId,
    String userName,
  ) async {
    try {
      // Create location entity
      final locationEntity = _locationService.positionToEntity(
        position: position,
        userId: userId,
        userName: userName,
        tripId: tripId,
      );

      // Update local state
      state = state.copyWith(
        currentUserLocation: locationEntity,
        lastLocationUpdate: DateTime.now(),
      );

      // Update API
      final result = await _locationRepository.updateLocation(
        tripId: tripId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      result.fold(
        (failure) {
          log('Failed to update location on server: ${failure.message}');
        },
        (_) {
          // Emit socket event for real-time updates
          _socketService.emitUpdateLocation(
            tripId: tripId,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
          );
        },
      );
    } catch (e) {
      log('Error handling location update: $e');
    }
  }

  /// Stop location sharing
  Future<void> stopSharing(String tripId) async {
    if (state.isStopping || !state.isSharing) return;

    state = state.copyWith(isStopping: true, error: null);

    try {
      // Cancel location stream
      await _locationStreamSubscription?.cancel();
      _locationStreamSubscription = null;

      // Call API to stop location sharing
      final result = await _locationRepository.stopLocationSharing(tripId);

      result.fold(
        (failure) {
          state = state.copyWith(isStopping: false, error: failure.message);
        },
        (_) {
          // Emit socket event
          _socketService.emitStopLocationSharing(tripId: tripId);

          // Leave trip's location room
          _socketService.leaveTripLocationRoom(tripId);

          state = state.copyWith(
            isSharing: false,
            isStopping: false,
            currentTripId: null,
            currentUserLocation: null,
          );

          log('Stopped location sharing for trip $tripId');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isStopping: false,
        error: 'Failed to stop location sharing: $e',
      );
      log('Error stopping location sharing: $e');
    }
  }

  /// Load all trip member locations
  Future<void> loadTripLocations(String tripId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _locationRepository.getTripLocations(tripId);

      result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (locations) {
          state = state.copyWith(
            locations: locations,
            isLoading: false,
            lastLocationUpdate: DateTime.now(),
          );

          log('Loaded ${locations.length} locations for trip $tripId');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load trip locations: $e',
      );
      log('Error loading trip locations: $e');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clean up resources
  void dispose() {
    _locationStreamSubscription?.cancel();
    _locationStreamSubscription = null;
  }
}

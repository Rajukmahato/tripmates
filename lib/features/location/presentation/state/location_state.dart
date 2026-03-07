import 'package:equatable/equatable.dart';
import 'package:tripmates/features/location/domain/entities/location_entity.dart';

/// State for location sharing feature
class LocationState extends Equatable {
  /// All member locations for the current trip
  final List<LocationEntity> locations;

  /// Current user's own location
  final LocationEntity? currentUserLocation;

  /// Whether current user is actively sharing location
  final bool isSharing;

  /// Loading state for fetching trip locations
  final bool isLoading;

  /// Starting location sharing (permission + GPS initialization)
  final bool isStarting;

  /// Stopping location sharing
  final bool isStopping;

  /// Error message
  final String? error;

  /// Current trip ID being tracked
  final String? currentTripId;

  /// Whether location permission is granted
  final bool hasPermission;

  /// Last time location was updated
  final DateTime? lastLocationUpdate;

  const LocationState({
    this.locations = const [],
    this.currentUserLocation,
    this.isSharing = false,
    this.isLoading = false,
    this.isStarting = false,
    this.isStopping = false,
    this.error,
    this.currentTripId,
    this.hasPermission = false,
    this.lastLocationUpdate,
  });

  @override
  List<Object?> get props => [
    locations,
    currentUserLocation,
    isSharing,
    isLoading,
    isStarting,
    isStopping,
    error,
    currentTripId,
    hasPermission,
    lastLocationUpdate,
  ];

  LocationState copyWith({
    List<LocationEntity>? locations,
    LocationEntity? currentUserLocation,
    bool? isSharing,
    bool? isLoading,
    bool? isStarting,
    bool? isStopping,
    String? error,
    String? currentTripId,
    bool? hasPermission,
    DateTime? lastLocationUpdate,
  }) {
    return LocationState(
      locations: locations ?? this.locations,
      currentUserLocation: currentUserLocation ?? this.currentUserLocation,
      isSharing: isSharing ?? this.isSharing,
      isLoading: isLoading ?? this.isLoading,
      isStarting: isStarting ?? this.isStarting,
      isStopping: isStopping ?? this.isStopping,
      error: error,
      currentTripId: currentTripId ?? this.currentTripId,
      hasPermission: hasPermission ?? this.hasPermission,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }

  /// Get locations excluding current user
  List<LocationEntity> get otherMemberLocations {
    if (currentUserLocation == null) return locations;
    return locations
        .where((loc) => loc.userId != currentUserLocation!.userId)
        .toList();
  }

  /// Get number of members sharing location
  int get activeShareCount => locations.length;

  /// Whether location is stale (older than 5 minutes)
  bool get isLocationStale {
    if (lastLocationUpdate == null) return true;
    final difference = DateTime.now().difference(lastLocationUpdate!);
    return difference.inMinutes > 5;
  }
}

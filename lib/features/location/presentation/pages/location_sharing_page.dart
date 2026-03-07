import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/features/location/domain/entities/location_entity.dart';
import 'package:tripmates/features/location/presentation/state/location_state.dart';
import 'package:tripmates/features/location/presentation/viewmodel/location_viewmodel.dart';

class LocationSharingPage extends ConsumerStatefulWidget {
  final String tripId;
  final String tripName;

  const LocationSharingPage({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  ConsumerState<LocationSharingPage> createState() =>
      _LocationSharingPageState();
}

class _LocationSharingPageState extends ConsumerState<LocationSharingPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _showMemberList = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load existing trip member locations
      ref
          .read(locationViewModelProvider.notifier)
          .loadTripLocations(widget.tripId);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateCamera();
  }

  void _updateCamera() {
    final state = ref.read(locationViewModelProvider);
    if (_mapController == null || state.currentUserLocation == null) return;

    final location = state.currentUserLocation!;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        15.0,
      ),
    );
  }

  void _centerOnCurrentUser() {
    final state = ref.read(locationViewModelProvider);
    if (_mapController == null || state.currentUserLocation == null) return;

    final location = state.currentUserLocation!;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        16.0,
      ),
    );
  }

  void _updateMarkers(LocationState state) {
    _markers.clear();

    // Add current user marker (blue)
    if (state.currentUserLocation != null) {
      _markers.add(
        _createMarker(state.currentUserLocation!, isCurrentUser: true),
      );
    }

    // Add other member markers (red)
    for (final location in state.otherMemberLocations) {
      _markers.add(_createMarker(location, isCurrentUser: false));
    }
  }

  Marker _createMarker(LocationEntity location, {required bool isCurrentUser}) {
    return Marker(
      markerId: MarkerId(location.userId),
      position: LatLng(location.latitude, location.longitude),
      icon: isCurrentUser
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: location.userName,
        snippet: _formatTimestamp(location.timestamp),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  Future<void> _toggleSharing() async {
    final viewModel = ref.read(locationViewModelProvider.notifier);
    final state = ref.read(locationViewModelProvider);

    if (state.isSharing) {
      await viewModel.stopSharing(widget.tripId);
    } else {
      // Check permission first
      final hasPermission = await viewModel.checkPermission();
      if (!hasPermission) {
        if (!mounted) return;
        final granted = await _showPermissionDialog();
        if (!granted) return;
      }

      await viewModel.startSharing(widget.tripId);
      _updateCamera();
    }
  }

  Future<bool> _showPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to share your location with trip members. '
          'Location data is only shared when you explicitly start sharing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              final viewModel = ref.read(locationViewModelProvider.notifier);
              final granted = await viewModel.requestPermission();
              if (granted) {
                await viewModel.startSharing(widget.tripId);
              }
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationViewModelProvider);

    // Update markers whenever state changes
    _updateMarkers(state);

    // Auto-update camera when location changes
    if (state.isSharing && state.currentUserLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null) {
          final location = state.currentUserLocation!;
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(location.latitude, location.longitude),
            ),
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.tripName, style: const TextStyle(fontSize: 18)),
            Text(
              '${state.activeShareCount} sharing location',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showMemberList ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _showMemberList = !_showMemberList;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          state.currentUserLocation != null || state.locations.isNotEmpty
              ? GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: state.currentUserLocation != null
                        ? LatLng(
                            state.currentUserLocation!.latitude,
                            state.currentUserLocation!.longitude,
                          )
                        : state.locations.isNotEmpty
                        ? LatLng(
                            state.locations.first.latitude,
                            state.locations.first.longitude,
                          )
                        : const LatLng(0, 0),
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: state.isSharing,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                )
              : _buildEmptyState(),

          // Loading indicator
          if (state.isLoading || state.isStarting)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Error banner
          if (state.error != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          ref
                              .read(locationViewModelProvider.notifier)
                              .clearError();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Member list bottom sheet
          if (_showMemberList)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildMemberList(state),
            ),

          // Center on me FAB
          if (state.isSharing)
            Positioned(
              bottom: _showMemberList ? 220 : 90,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'center',
                onPressed: _centerOnCurrentUser,
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: AppColors.primary),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isStarting || state.isStopping ? null : _toggleSharing,
        backgroundColor: state.isSharing ? Colors.red : AppColors.primary,
        icon: Icon(
          state.isSharing ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
        ),
        label: Text(
          state.isSharing
              ? (state.isStopping ? 'Stopping...' : 'Stop Sharing')
              : (state.isStarting ? 'Starting...' : 'Share Location'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No locations to display',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start sharing to see your location',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(LocationState state) {
    final allLocations = [
      if (state.currentUserLocation != null) state.currentUserLocation!,
      ...state.otherMemberLocations,
    ];

    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trip Members (${allLocations.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showMemberList = false;
                    });
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allLocations.length,
              itemBuilder: (context, index) {
                final location = allLocations[index];
                final isCurrentUser =
                    location.userId == state.currentUserLocation?.userId;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentUser ? Colors.blue : Colors.red,
                    child: Text(
                      location.userName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    isCurrentUser
                        ? '${location.userName} (You)'
                        : location.userName,
                  ),
                  subtitle: Text(_formatTimestamp(location.timestamp)),
                  trailing: location.accuracy != null
                      ? Text(
                          '±${location.accuracy!.toInt()}m',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                  onTap: () {
                    if (_mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(location.latitude, location.longitude),
                          16.0,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

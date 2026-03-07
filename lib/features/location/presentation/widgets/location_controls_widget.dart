import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/features/location/presentation/viewmodel/location_viewmodel.dart';

/// Reusable widget for location sharing controls
class LocationControlsWidget extends ConsumerWidget {
  final String tripId;
  final VoidCallback? onSharePressed;

  const LocationControlsWidget({
    super.key,
    required this.tripId,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationViewModelProvider);
    final viewModel = ref.read(locationViewModelProvider.notifier);

    final isActive = state.isSharing && state.currentTripId == tripId;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.location_on : Icons.location_off,
                  color: isActive ? Colors.green : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Sharing',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive
                            ? 'Sharing your location with trip members'
                            : 'Share your location in real-time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: state.isStarting || state.isStopping
                      ? null
                      : (value) async {
                          if (value) {
                            await _startSharing(context, ref, tripId);
                          } else {
                            await viewModel.stopSharing(tripId);
                          }
                        },
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),

            // Status indicators
            if (isActive) ...[
              const Divider(height: 24),
              _buildStatusRow(
                context,
                icon: Icons.access_time,
                label: 'Last updated',
                value: _formatLastUpdate(state.lastLocationUpdate),
                color: state.isLocationStale ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 8),
              if (state.currentUserLocation?.accuracy != null)
                _buildStatusRow(
                  context,
                  icon: Icons.my_location,
                  label: 'Accuracy',
                  value: '±${state.currentUserLocation!.accuracy!.toInt()}m',
                  color: _getAccuracyColor(
                    state.currentUserLocation!.accuracy!,
                  ),
                ),
              const SizedBox(height: 8),
              _buildStatusRow(
                context,
                icon: Icons.people,
                label: 'Members sharing',
                value: '${state.activeShareCount}',
                color: AppColors.primary,
              ),
            ],

            // Permission warning
            if (!state.hasPermission && !isActive) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location permission required to share',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error message
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: TextStyle(fontSize: 12, color: Colors.red[900]),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => viewModel.clearError(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],

            // View full map button
            if (state.locations.isNotEmpty || isActive) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSharePressed,
                  icon: const Icon(Icons.map),
                  label: const Text('View on Map'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],

            // Loading indicator
            if (state.isStarting || state.isStopping) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                state.isStarting
                    ? 'Starting location sharing...'
                    : 'Stopping location sharing...',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startSharing(
    BuildContext context,
    WidgetRef ref,
    String tripId,
  ) async {
    final viewModel = ref.read(locationViewModelProvider.notifier);

    // Check permission
    final hasPermission = await viewModel.checkPermission();
    if (!hasPermission) {
      if (!context.mounted) return;
      final granted = await _showPermissionDialog(context, ref);
      if (!granted) return;
    }

    await viewModel.startSharing(tripId);
  }

  Future<bool> _showPermissionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final viewModel = ref.read(locationViewModelProvider.notifier);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Location Permission'),
          ],
        ),
        content: const Text(
          'To share your location with trip members, we need access to your device location. '
          '\n\nYour location is only shared when you explicitly enable sharing and only with members of this trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await viewModel.requestPermission();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Widget _buildStatusRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatLastUpdate(DateTime? timestamp) {
    if (timestamp == null) return 'Never';

    final difference = DateTime.now().difference(timestamp);

    if (difference.inSeconds < 10) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy < 20) return Colors.green;
    if (accuracy < 50) return Colors.orange;
    return Colors.red;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/presentation/view_model/trip_viewmodel.dart';
import 'package:tripmates/core/providers/app_providers.dart';

class JoinRequestDialog extends ConsumerWidget {
  final TripEntity trip;

  const JoinRequestDialog({super.key, required this.trip});

  Future<void> _handleJoinRequest(BuildContext context, WidgetRef ref) async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId();

    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      }
      return;
    }

    final tripNotifier = ref.read(tripViewModelProvider.notifier);
    final success = await tripNotifier.sendJoinRequest(
      tripId: trip.tripId ?? '',
      userId: userId,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Join request sent! Awaiting confirmation.'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to send join request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Join Trip'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip: ${trip.tripName}'),
          const SizedBox(height: 8),
          Text('Destination: ${trip.destination}'),
          const SizedBox(height: 8),
          Text('Starts: ${trip.startDate.toString().split(' ')[0]}'),
          const SizedBox(height: 16),
          const Text('Send a request to join this trip!'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _handleJoinRequest(context, ref),
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}

class TripDetailActionButton extends ConsumerWidget {
  final TripEntity trip;
  final VoidCallback? onEdit;
  final VoidCallback? onLeave;
  final VoidCallback? onJoin;

  const TripDetailActionButton({
    super.key,
    required this.trip,
    this.onEdit,
    this.onLeave,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserSession = ref.watch(currentUserSessionProvider);

    return currentUserSession.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
      data: (session) {
        final currentUserId = session?['userId'] as String?;
        final tripData = trip; // trip is available from the class property
        final isOwner = tripData.createdBy == currentUserId;
        final isMember =
            tripData.members?.any((m) => m.userId == currentUserId) ?? false;

        if (isOwner) {
          return ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Trip'),
          );
        } else if (isMember) {
          return ElevatedButton.icon(
            onPressed: onLeave,
            icon: const Icon(Icons.logout),
            label: const Text('Leave Trip'),
          );
        } else {
          return ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => JoinRequestDialog(trip: tripData),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Join Trip'),
          );
        }
      },
    );
  }
}

class TripDetailsSection extends StatelessWidget {
  final TripEntity trip;

  const TripDetailsSection({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distance & Duration
          if (trip.distanceMin != null || trip.durationMinHours != null)
            Row(
              children: [
                if (trip.distanceMin != null)
                  Expanded(
                    child: _buildDetailCard(
                      'Distance',
                      '${trip.distanceMin?.toStringAsFixed(1)} km',
                      Icons.location_on,
                    ),
                  ),
                const SizedBox(width: 12),
                if (trip.durationMinHours != null)
                  Expanded(
                    child: _buildDetailCard(
                      'Duration',
                      '${trip.durationMinHours}h',
                      Icons.schedule,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 16),

          // Difficulty & Fitness
          if (trip.difficultyLevel != null || trip.fitnessLevel != null)
            Row(
              children: [
                if (trip.difficultyLevel != null)
                  Expanded(
                    child: _buildDetailCard(
                      'Difficulty',
                      trip.difficultyLevel ?? 'N/A',
                      Icons.terrain,
                    ),
                  ),
                const SizedBox(width: 12),
                if (trip.fitnessLevel != null)
                  Expanded(
                    child: _buildDetailCard(
                      'Fitness',
                      trip.fitnessLevel ?? 'N/A',
                      Icons.favorite,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 16),

          // Elevation
          if (trip.elevationMin != null || trip.elevationMax != null)
            _buildDetailCard(
              'Elevation Range',
              '${trip.elevationMin ?? 0}m - ${trip.elevationMax ?? 0}m',
              Icons.height,
            ),

          const SizedBox(height: 16),

          // Best Season
          if (trip.bestSeason != null)
            _buildDetailCard(
              'Best Season',
              trip.bestSeason ?? 'N/A',
              Icons.cloud,
            ),

          const SizedBox(height: 16),

          // Activities
          if (trip.activities != null && trip.activities!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activities',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trip.activities!
                      .map((activity) => Chip(label: Text(activity)))
                      .toList(),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Meal & Accommodation
          if (trip.mealsIncluded != null || trip.accommodationType != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trip.mealsIncluded != null)
                  _buildDetailRow(
                    'Meals Included',
                    trip.mealsIncluded ?? 'N/A',
                  ),
                if (trip.accommodationType != null)
                  _buildDetailRow(
                    'Accommodation',
                    trip.accommodationType ?? 'N/A',
                  ),
              ],
            ),

          const SizedBox(height: 16),

          // Highlights
          if (trip.highlights != null && trip.highlights!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Highlights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...trip.highlights!.map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(h)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

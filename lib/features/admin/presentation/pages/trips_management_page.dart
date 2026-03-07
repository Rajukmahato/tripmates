import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/extensions/context_extensions.dart';
import 'package:tripmates/features/admin/domain/entities/admin_trip_entity.dart';
import 'package:tripmates/features/admin/presentation/viewmodel/admin_viewmodel.dart';
import 'package:tripmates/features/admin/presentation/widgets/trip_action_dialog.dart';

/// Trips management page for admin
class TripsManagementPage extends ConsumerStatefulWidget {
  const TripsManagementPage({super.key});

  @override
  ConsumerState<TripsManagementPage> createState() =>
      _TripsManagementPageState();
}

class _TripsManagementPageState extends ConsumerState<TripsManagementPage> {
  String _searchQuery = '';
  String _filter = 'all'; // all, active, inactive, featured

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminViewmodelProvider.notifier).loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminViewmodelProvider);
    final trips = _getFilteredTrips(adminState.trips);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Trips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search trips...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: context.surfaceColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All (${adminState.trips.length})',
                        isSelected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Active (${adminState.activeTripsCount})',
                        isSelected: _filter == 'active',
                        onTap: () => setState(() => _filter = 'active'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Inactive',
                        isSelected: _filter == 'inactive',
                        onTap: () => setState(() => _filter = 'inactive'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Featured',
                        isSelected: _filter == 'featured',
                        onTap: () => setState(() => _filter = 'featured'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Trips List
          Expanded(
            child: adminState.isTripsLoading
                ? const Center(child: CircularProgressIndicator())
                : trips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.luggage,
                          size: 64,
                          color: context.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No trips found',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(adminViewmodelProvider.notifier).loadTrips(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: trips.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return _TripCard(trip: trip, ref: ref);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<AdminTripEntity> _getFilteredTrips(List<AdminTripEntity> trips) {
    var filtered = trips;

    // Apply status filter
    if (_filter == 'active') {
      filtered = filtered.where((t) => t.isActive).toList();
    } else if (_filter == 'inactive') {
      filtered = filtered.where((t) => !t.isActive).toList();
    } else if (_filter == 'featured') {
      filtered = filtered.where((t) => t.isFeatured).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.tripName.toLowerCase().contains(_searchQuery) ||
                t.destination.toLowerCase().contains(_searchQuery) ||
                t.creatorName.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    return filtered;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : context.surfaceColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : context.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TripCard extends ConsumerWidget {
  final AdminTripEntity trip;
  final WidgetRef ref;

  const _TripCard({required this.trip, required this.ref});

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return Colors.blue;
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showTripActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TripActionDialog(
        tripId: trip.id,
        tripName: trip.tripName,
        isActive: trip.isActive,
        onConfirm: (newStatus) {
          ref
              .read(adminViewmodelProvider.notifier)
              .toggleTripStatus(trip.id, newStatus);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus
                    ? 'Trip activated successfully'
                    : 'Trip deactivated successfully',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFeatureTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FeatureTripDialog(
        tripId: trip.id,
        tripName: trip.tripName,
        isFeatured: trip.isFeatured,
        onConfirm: (featured) {
          ref
              .read(adminViewmodelProvider.notifier)
              .featureTrip(trip.id, featured);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                featured
                    ? 'Trip featured successfully'
                    : 'Trip unfeature successfully',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DeleteTripDialog(
        tripId: trip.id,
        tripName: trip.tripName,
        onConfirm: (reason) {
          ref.read(adminViewmodelProvider.notifier).deleteTrip(trip.id, reason);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip deleted successfully')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.cardShadow,
        border: trip.isFeatured
            ? Border.all(color: Colors.amber, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (trip.isFeatured)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            trip.tripName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: context.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            trip.destination,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(trip.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(trip.status),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Creator Info
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: trip.creatorAvatar != null
                    ? NetworkImage(trip.creatorAvatar!)
                    : null,
                child: trip.creatorAvatar == null
                    ? Text(
                        trip.creatorName.isNotEmpty
                            ? trip.creatorName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'by ${trip.creatorName}',
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats Row
          Row(
            children: [
              _StatItem(
                icon: Icons.people_rounded,
                label: '${trip.participantsCount}/${trip.maxParticipants}',
              ),
              const SizedBox(width: 16),
              _StatItem(
                icon: Icons.calendar_today,
                label:
                    '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
              ),
              if (trip.reportsCount > 0) ...[
                const SizedBox(width: 16),
                _StatItem(
                  icon: Icons.flag_rounded,
                  label: '${trip.reportsCount} reports',
                  color: Colors.red,
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Active/Inactive Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: trip.isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trip.isActive ? Icons.check_circle : Icons.cancel,
                      size: 14,
                      color: trip.isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trip.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: trip.isActive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Status Toggle
              ElevatedButton.icon(
                onPressed: () => _showTripActionDialog(context),
                icon: Icon(
                  trip.isActive ? Icons.pause_circle : Icons.play_circle,
                  size: 16,
                ),
                label: Text(trip.isActive ? 'Deactivate' : 'Activate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: trip.isActive ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),

              // Feature/Unfeature
              ElevatedButton.icon(
                onPressed: () => _showFeatureTripDialog(context),
                icon: Icon(
                  trip.isFeatured ? Icons.star : Icons.star_outline,
                  size: 16,
                ),
                label: Text(trip.isFeatured ? 'Unfeature' : 'Feature'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: trip.isFeatured ? Colors.amber : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),

              // Delete Button (spans 2 columns)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteTripDialog(context),
                  icon: const Icon(Icons.delete_rounded, size: 16),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _StatItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.textSecondary;
    return Row(
      children: [
        Icon(icon, size: 14, color: effectiveColor),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: effectiveColor)),
      ],
    );
  }
}

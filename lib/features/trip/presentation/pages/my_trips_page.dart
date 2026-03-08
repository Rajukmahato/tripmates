import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/presentation/pages/trip_detail_page.dart';
import 'package:tripmates/features/trip/presentation/state/trip_state.dart';
import 'package:tripmates/features/trip/presentation/utils/user_trip_logic.dart';
import 'package:tripmates/features/trip/presentation/view_model/trip_viewmodel.dart';
import 'package:tripmates/features/category/presentation/view_model/category_viewmodel.dart';

class MyTripsPage extends ConsumerStatefulWidget {
  const MyTripsPage({super.key});

  @override
  ConsumerState<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends ConsumerState<MyTripsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadMyTrips());
  }

  void _loadMyTrips() {
    ref.read(tripViewModelProvider.notifier).getAllTrips();
    ref.read(categoryViewModelProvider.notifier).getAllCategories();
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Other';
    try {
      final categoryState = ref.read(categoryViewModelProvider);
      return categoryState.categories
          .firstWhere((c) => c.categoryId == categoryId)
          .categoryName;
    } catch (e) {
      return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripViewModelProvider);
    final userSessionService = ref.watch(userSessionServiceProvider);
    final currentUserId = userSessionService.getCurrentUserId() ?? '';
    final myTripsSections = getMyTripsSections(tripState.trips, currentUserId);
    final myTrips = [
      ...myTripsSections.planned,
      ...myTripsSections.ongoing,
      ...myTripsSections.completed,
    ];
    final userName = userSessionService.getCurrentUserFullName() ?? 'User';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'My Trips',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${myTrips.length} trips',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pending_actions_rounded,
                      title: 'Planned',
                      value: '${myTripsSections.planned.length}',
                      color: const Color(0xFF7C6BF7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.flight_takeoff_rounded,
                      title: 'Ongoing',
                      value: '${myTripsSections.ongoing.length}',
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_rounded,
                      title: 'Done',
                      value: '${myTripsSections.completed.length}',
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trips List
          tripState.status == TripStateStatus.loading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : myTrips.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.luggage_rounded,
                            size: 80,
                            color: context.textTertiary.withAlpha(128),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No trips yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start planning your next adventure!',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final trip = myTrips[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _TripCard(
                          trip: trip,
                          categoryName: _getCategoryName(trip.category),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripDetailPage(
                                  title: trip.tripName,
                                  location: trip.destination,
                                  category: _getCategoryName(trip.category),
                                  isLost:
                                      getUserTripPhase(trip) ==
                                      UserTripPhase.planned,
                                  description:
                                      trip.description ??
                                      'No description provided.',
                                  reportedBy: userName,
                                  imageUrl: trip.media,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }, childCount: myTrips.length),
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripEntity trip;
  final String categoryName;
  final VoidCallback onTap;

  const _TripCard({
    required this.trip,
    required this.categoryName,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (getUserTripPhase(trip)) {
      case UserTripPhase.planned:
        return AppColors.primary;
      case UserTripPhase.ongoing:
        return Colors.orange;
      case UserTripPhase.done:
        return Colors.green;
    }
  }

  String _getStatusLabel() {
    switch (getUserTripPhase(trip)) {
      case UserTripPhase.planned:
        return 'Planned';
      case UserTripPhase.ongoing:
        return 'Ongoing';
      case UserTripPhase.done:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Status Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: trip.media != null && trip.media!.isNotEmpty
                      ? (trip.media!.startsWith('http')
                            ? Image.network(
                                trip.media!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported_rounded,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 180,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                              )
                            : Image.file(
                                File(trip.media!),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image_rounded,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              ))
                      : Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.luggage_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                // Status Badge Overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: context.softShadow,
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.tripName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: context.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year} - ${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/presentation/pages/trip_detail_page.dart';
import 'package:tripmates/features/trip/presentation/state/trip_state.dart';
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
    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId();
    if (userId != null) {
      ref.read(tripViewModelProvider.notifier).getMyTrips(userId);
    }
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
                          '${tripState.trips.length} trips',
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
                      value:
                          '${tripState.trips.where((t) => t.status == TripStatus.planned).length}',
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.flight_takeoff_rounded,
                      title: 'Ongoing',
                      value:
                          '${tripState.trips.where((t) => t.status == TripStatus.ongoing).length}',
                      gradient: AppColors.lostGradient,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_rounded,
                      title: 'Done',
                      value:
                          '${tripState.trips.where((t) => t.status == TripStatus.completed).length}',
                      gradient: AppColors.foundGradient,
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
              : tripState.trips.isEmpty
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
                      final trip = tripState.trips[index];
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
                                  isLost: trip.status == TripStatus.planned,
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
                    }, childCount: tripState.trips.length),
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
  final Gradient gradient;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.softShadow,
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
    switch (trip.status) {
      case TripStatus.planned:
        return AppColors.primary;
      case TripStatus.ongoing:
        return Colors.orange;
      case TripStatus.completed:
        return Colors.green;
    }
  }

  String _getStatusLabel() {
    switch (trip.status) {
      case TripStatus.planned:
        return 'Planned';
      case TripStatus.ongoing:
        return 'Ongoing';
      case TripStatus.completed:
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: trip.media != null && trip.media!.isNotEmpty
                  ? (trip.media!.startsWith('http')
                        ? Image.network(
                            trip.media!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(trip.media!),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ))
                  : Container(
                      height: 160,
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.tripName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusLabel(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                    ],
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

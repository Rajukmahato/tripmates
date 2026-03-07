import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../trip/presentation/pages/enhanced_trip_detail_page.dart';
import '../../../trip/presentation/pages/trips_list_page.dart';
import '../../../trip/domain/entities/trip_entity.dart';
import '../../../trip/presentation/view_model/trip_viewmodel.dart';
import '../../../trip/presentation/state/trip_state.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/view_model/category_viewmodel.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/viewmodel/notification_viewmodel.dart';
import '../../../global_destinations/presentation/view_model/destination_viewmodel.dart';
import '../../../global_destinations/domain/entities/global_destination_entity.dart';
import '../../../global_destinations/presentation/pages/destinations_page.dart';
import '../../../global_destinations/presentation/pages/destination_detail_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;
  bool _hasLoadedData = false;
  String _searchQuery = '';

  bool _isUserTrip(TripEntity trip, String currentUserId) {
    // Home feed should hide only trips created by current user,
    // but still show trips the user has joined.
    return trip.createdBy == currentUserId;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!_hasLoadedData) {
        _hasLoadedData = true;
        ref.read(tripViewModelProvider.notifier).getAllTrips();
        ref.read(categoryViewModelProvider.notifier).getAllCategories();
        ref.read(destinationViewModelProvider.notifier).getAllDestinations();
        // Load notifications and unread count
        ref.read(notificationViewmodelProvider.notifier).loadNotifications();
      }
    });
  }

  /// Determine if trip is planned based on start date (using server time)
  /// Includes trips starting today or later
  bool _isTripPlanned(TripEntity trip, timeService) {
    try {
      final currentServerTime = timeService.getCurrentServerTime();
      final currentDate = DateTime(
        currentServerTime.year,
        currentServerTime.month,
        currentServerTime.day,
      );
      final startDate = DateTime(
        trip.startDate.year,
        trip.startDate.month,
        trip.startDate.day,
      );
      final isPlanned = !startDate.isBefore(currentDate); // today or future
      return isPlanned;
    } catch (e) {
      // Fallback to device time if server time fails
      debugPrint('Error in _isTripPlanned: $e');
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, now.day);
      final startDate = DateTime(
        trip.startDate.year,
        trip.startDate.month,
        trip.startDate.day,
      );
      return !startDate.isBefore(currentDate); // today or future
    }
  }

  /// Determine if trip is completed based on end date (using server time)
  bool _isTripCompleted(TripEntity trip, timeService) {
    try {
      final currentServerTime = timeService.getCurrentServerTime();
      final currentDate = DateTime(
        currentServerTime.year,
        currentServerTime.month,
        currentServerTime.day,
      );
      final endDate = DateTime(
        trip.endDate.year,
        trip.endDate.month,
        trip.endDate.day,
      );
      final isCompleted = endDate.isBefore(currentDate);
      return isCompleted;
    } catch (e) {
      // Fallback to device time if server time fails
      debugPrint('Error in _isTripCompleted: $e');
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, now.day);
      final endDate = DateTime(
        trip.endDate.year,
        trip.endDate.month,
        trip.endDate.day,
      );
      return endDate.isBefore(currentDate);
    }
  }

  List<TripEntity> _getFilteredTrips(
    TripState tripState,
    timeService,
    String currentUserId,
  ) {
    try {
      debugPrint('\n========== FILTERING TRIPS ==========');
      debugPrint('Total trips from backend: ${tripState.trips.length}');
      debugPrint('Current user ID: $currentUserId');

      // Log each trip and why it's included/excluded
      for (var trip in tripState.trips) {
        final isUserTrip = _isUserTrip(trip, currentUserId);
        final isPlanned = _isTripPlanned(trip, timeService);
        final included = !isUserTrip && isPlanned;

        debugPrint(
          '\nTrip: "${trip.tripName}" (ID: ${trip.tripId})'
          '\n  Start: ${trip.startDate.toString().split(' ')[0]}'
          '\n  Creator: ${trip.createdBy}'
          '\n  Members: ${trip.members?.length ?? 0}'
          '\n  Is user trip? $isUserTrip'
          '\n  Is planned? $isPlanned'
          '\n  >>> ${included ? "✅ INCLUDED" : "❌ EXCLUDED"}',
        );
      }

      List<TripEntity> trips = tripState.trips
          .where(
            (trip) =>
                !_isUserTrip(trip, currentUserId) &&
                _isTripPlanned(trip, timeService),
          )
          .toList();

      debugPrint('\n========== FILTER RESULT ==========');
      debugPrint('Filtered trips (upcoming): ${trips.length}');

      // Filter by category
      if (_selectedCategoryId != null) {
        trips = trips
            .where((trip) => trip.category == _selectedCategoryId)
            .toList();
        debugPrint('After category filter: ${trips.length} trips');
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        trips = trips.where((trip) {
          final tripName = trip.tripName.toLowerCase();
          final destination = trip.destination.toLowerCase();
          return tripName.contains(_searchQuery) ||
              destination.contains(_searchQuery);
        }).toList();
        debugPrint(
          'After search filter "$_searchQuery": ${trips.length} trips',
        );
      }

      debugPrint('=====================================\n');
      return trips;
    } catch (e) {
      // Return all trips if filtering fails
      debugPrint('Error in _getFilteredTrips: $e');
      return tripState.trips;
    }
  }

  /// Determine trip status: 'planned', 'active', or 'completed'
  String _getTripStatus(TripEntity trip, timeService, String currentUserId) {
    if (_isTripPlanned(trip, timeService)) {
      return 'planned';
    } else if (_isTripCompleted(trip, timeService)) {
      return 'completed';
    } else {
      return 'active';
    }
  }

  String _getCategoryNameById(
    String? categoryId,
    List<CategoryEntity> categories,
  ) {
    if (categoryId == null) return 'Other';
    try {
      return categories
          .firstWhere((c) => c.categoryId == categoryId)
          .categoryName;
    } catch (e) {
      return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final tripState = ref.watch(tripViewModelProvider);
      final categoryState = ref.watch(categoryViewModelProvider);
      final serverTimeService = ref.watch(serverTimeServiceProvider);
      final userSessionService = ref.watch(userSessionServiceProvider);
      final currentUserId = userSessionService.getCurrentUserId() ?? '';
      final filteredTrips = _getFilteredTrips(
        tripState,
        serverTimeService,
        currentUserId,
      );
      final userName = userSessionService.getCurrentUserFullName() ?? 'User';
      final screenWidth = MediaQuery.of(context).size.width;
      final crossAxisCount = screenWidth < 360
          ? 1
          : screenWidth < 900
          ? 2
          : 3;
      final childAspectRatio = crossAxisCount == 1
          ? 1.9
          : crossAxisCount == 2
          ? 0.82 // Increased height to prevent overflow (was 0.9)
          : 1.25;

      // Debug logging
      debugPrint(
        'HomeScreen build - Total trips: ${tripState.trips.length}, Filtered: ${filteredTrips.length}, Status: ${tripState.status}',
      );
      debugPrint(
        'Trip names: ${tripState.trips.map((t) => t.tripName).join(", ")}',
      );
      debugPrint(
        'Filtered trip names: ${filteredTrips.map((t) => t.tripName).join(", ")}',
      );

      return Scaffold(
        // backgroundColor: context.backgroundColor // Using theme default,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 16,
                              color: context.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.notifications_rounded,
                                  color: context.textPrimary,
                                  size: 24,
                                ),
                              ),
                              // Dynamic unread count badge
                              Consumer(
                                builder: (context, ref, child) {
                                  final unreadCount = ref.watch(
                                    unreadCountProvider,
                                  );
                                  if (unreadCount == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppColors.lostColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: context.softShadow,
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search trips by name or destination...',
                        hintStyle: TextStyle(color: context.textTertiary),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: context.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Featured Destinations Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Destinations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DestinationsPage(),
                            ),
                          );
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Destinations List
              Consumer(
                builder: (context, ref, child) {
                  final destinationState = ref.watch(
                    destinationViewModelProvider,
                  );
                  final destinations = destinationState.destinations
                      .take(5)
                      .toList();

                  if (destinations.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: destinations.length,
                        itemBuilder: (context, index) {
                          final destination = destinations[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _DestinationCard(
                              destination: destination,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DestinationDetailPage(
                                      destination: destination,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Upcoming Trips Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Trips',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TripsListPage(),
                            ),
                          );
                        },
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Trips Grid
              tripState.status == TripStateStatus.loading
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : filteredTrips.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 64,
                                color: context.textTertiary.withAlpha(128),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No trips found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start planning your next adventure!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final trip = filteredTrips[index];
                          final categoryName = _getCategoryNameById(
                            trip.category,
                            categoryState.categories,
                          );
                          return _ItemCard(
                            title: trip.tripName,
                            location: trip.destination,
                            category: categoryName,
                            imageUrl: trip.media,
                            startDate: trip.startDate,
                            endDate: trip.endDate,
                            price: trip.budget,
                            tripStatus: _getTripStatus(
                              trip,
                              serverTimeService,
                              currentUserId,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EnhancedTripDetailPage(trip: trip),
                                ),
                              );
                            },
                          );
                        }, childCount: filteredTrips.length),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      // Error handler - show error screen
      debugPrint('HomeScreen build error: $e');
      debugPrint('Stack trace: $stackTrace');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error loading home screen'),
              const SizedBox(height: 8),
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(tripViewModelProvider.notifier).getAllTrips();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _ItemCard extends StatelessWidget {
  final String title;
  final String location;
  final String category;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final double? price;
  final String tripStatus; // 'planned', 'active', or 'completed'
  final VoidCallback? onTap;

  const _ItemCard({
    required this.title,
    required this.location,
    required this.category,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.price,
    required this.tripStatus,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatPrice(double? amount) {
    if (amount == null) return 'N/A';
    if (amount == amount.roundToDouble()) {
      return '\$${amount.toInt()}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices_rounded;
      case 'Personal':
        return Icons.person_rounded;
      case 'Accessories':
        return Icons.watch_rounded;
      case 'Documents':
        return Icons.description_rounded;
      case 'Keys':
        return Icons.key_rounded;
      case 'Bags':
        return Icons.backpack_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: imageUrl != null
                              ? Image.network(imageUrl!, fit: BoxFit.cover)
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: tripStatus == 'planned'
                                        ? AppColors.lostGradient
                                        : tripStatus == 'completed'
                                        ? AppColors.foundGradient
                                        : AppColors.primaryGradient,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getCategoryIcon(category),
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.35),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatPrice(price),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tripStatus == 'planned'
                            ? Colors.blue.withAlpha(26)
                            : tripStatus == 'completed'
                            ? Colors.grey.withAlpha(51)
                            : AppColors.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tripStatus == 'planned'
                            ? 'Upcoming'
                            : tripStatus == 'completed'
                            ? 'Expired'
                            : 'Active',
                        style: TextStyle(
                          fontSize: 10,
                          color: tripStatus == 'planned'
                              ? Colors.blue[700]
                              : tripStatus == 'completed'
                              ? Colors.grey[700]
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      size: 14,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ' ${_formatDate(startDate)} - ${_formatDate(endDate)}',
                        style: TextStyle(
                          fontSize: 11,
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
                      Icons.location_on_rounded,
                      size: 14,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
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
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final GlobalDestinationEntity destination;
  final VoidCallback? onTap;

  const _DestinationCard({required this.destination, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: context.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              if (destination.primaryImage != null)
                Image.network(
                  destination.primaryImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                    );
                  },
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.country,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (destination.tripCount != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${destination.tripCount} trips',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/trip/presentation/state/trip_state.dart';
import 'package:tripmates/features/trip/presentation/view_model/trip_viewmodel.dart';
import 'package:tripmates/features/trip/presentation/widgets/trip_card.dart';
import 'package:tripmates/features/trip/presentation/widgets/advanced_filters_widget.dart';
import 'package:tripmates/features/trip/presentation/pages/enhanced_trip_detail_page.dart';
import 'package:tripmates/features/trip/presentation/pages/add_trip_page.dart';

/// Page to browse all available trips
class TripsListPage extends ConsumerStatefulWidget {
  const TripsListPage({super.key});

  @override
  ConsumerState<TripsListPage> createState() => _TripsListPageState();
}

class _TripsListPageState extends ConsumerState<TripsListPage> {
  late ScrollController _scrollController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial trips
    Future.microtask(() {
      ref.read(tripViewModelProvider.notifier).getAllTrips();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more trips on scroll to bottom (pagination)
      ref.read(tripViewModelProvider.notifier).loadMoreTrips();
    }
  }

  void _showAdvancedFilters(BuildContext context, TripState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdvancedFiltersDialog(
          initialFilters: state.activeFilters ?? const TripFilters(),
          onApply: (filters) {
            ref.read(tripViewModelProvider.notifier).applyFilters(filters);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Trips'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible:
                  tripState.activeFilters != null &&
                  !tripState.activeFilters!.isEmpty,
              label: const Text('F'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _showAdvancedFilters(context, tripState),
            tooltip: 'Advanced Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Show active filters badge
          if (tripState.activeFilters != null &&
              !tripState.activeFilters!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (tripState.activeFilters!.difficulty != null)
                    Chip(
                      label: Text(
                        'Difficulty: ${tripState.activeFilters!.difficulty}',
                      ),
                      onDeleted: () {
                        ref
                            .read(tripViewModelProvider.notifier)
                            .applyFilters(
                              tripState.activeFilters!.copyWith(
                                difficulty: null,
                              ),
                            );
                      },
                    ),
                  if (tripState.activeFilters!.season != null)
                    Chip(
                      label: Text('Season: ${tripState.activeFilters!.season}'),
                      onDeleted: () {
                        ref
                            .read(tripViewModelProvider.notifier)
                            .applyFilters(
                              tripState.activeFilters!.copyWith(season: null),
                            );
                      },
                    ),
                  if (tripState.activeFilters!.selectedActivities != null &&
                      tripState.activeFilters!.selectedActivities!.isNotEmpty)
                    Chip(
                      label: Text(
                        'Activities: ${tripState.activeFilters!.selectedActivities!.length}',
                      ),
                      onDeleted: () {
                        ref
                            .read(tripViewModelProvider.notifier)
                            .applyFilters(
                              tripState.activeFilters!.copyWith(
                                selectedActivities: null,
                              ),
                            );
                      },
                    ),
                  TextButton(
                    onPressed: () {
                      ref.read(tripViewModelProvider.notifier).clearFilters();
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),

          // Search and Filter
          TripSearchBar(
            onSearch: (query) {
              setState(() => _searchQuery = query);
              if (query.isNotEmpty) {
                ref
                    .read(tripViewModelProvider.notifier)
                    .searchTrips(_searchQuery);
              } else {
                ref.read(tripViewModelProvider.notifier).getAllTrips();
              }
            },
            onDestinationFilter: (destination) {
              ref
                  .read(tripViewModelProvider.notifier)
                  .filterByDestination(destination);
            },
          ),

          // Trip List
          Expanded(
            child: tripState.status == TripStateStatus.loading
                ? const TripListLoading()
                : tripState.trips.isEmpty
                ? TripEmptyState(
                    onCreateTrip: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTripPage(),
                        ),
                      );
                    },
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.read(tripViewModelProvider.notifier).getAllTrips();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: tripState.trips.length,
                      itemBuilder: (context, index) {
                        final trip = tripState.trips[index];
                        log(
                          'Rendering TripCard #$index: ${trip.tripName} - budget: ${trip.budget}, members: ${trip.groupSizeMax}, rating: ${trip.averageRating}',
                        );
                        return TripCard(
                          tripId: trip.tripId ?? '',
                          destination: trip.destination,
                          title: trip.tripName,
                          imageUrl: trip.media,
                          price: trip.budget,
                          members: trip.groupSizeMax ?? 0,
                          rating: trip.averageRating ?? 0.0,
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
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

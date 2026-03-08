import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/presentation/state/destination_state.dart';
import 'package:tripmates/features/global_destinations/presentation/view_model/destination_viewmodel.dart';
import 'package:tripmates/features/global_destinations/presentation/pages/destination_detail_page.dart';

class DestinationsPage extends ConsumerStatefulWidget {
  const DestinationsPage({super.key});

  @override
  ConsumerState<DestinationsPage> createState() => _DestinationsPageState();
}

class _DestinationsPageState extends ConsumerState<DestinationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCountry;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(destinationViewModelProvider.notifier).getAllDestinations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Set<String> _getCountries(List<GlobalDestinationEntity> destinations) {
    return destinations.map((d) => d.country).toSet();
  }

  List<GlobalDestinationEntity> _filterDestinations(
    List<GlobalDestinationEntity> destinations,
  ) {
    if (_selectedCountry == null) return destinations;
    return destinations.where((d) => d.country == _selectedCountry).toList();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      ref.read(destinationViewModelProvider.notifier).clearSearch();
    } else {
      ref
          .read(destinationViewModelProvider.notifier)
          .searchDestinations(query: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationState = ref.watch(destinationViewModelProvider);
    final countries = _getCountries(destinationState.destinations);
    final filteredDestinations = _filterDestinations(
      destinationState.destinations,
    );

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(destinationViewModelProvider.notifier)
              .getAllDestinations();
        },
        child: CustomScrollView(
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
                          const Text(
                            'Global Destinations',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${filteredDestinations.length} amazing places',
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

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: context.softShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _performSearch,
                    decoration: InputDecoration(
                      hintText: 'Search destinations...',
                      hintStyle: TextStyle(color: context.textTertiary),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: context.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                _isGridView
                                    ? Icons.view_list_rounded
                                    : Icons.grid_view_rounded,
                                color: context.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isGridView = !_isGridView;
                                });
                              },
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

            // Country Filter Chips
            if (countries.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: countries.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedCountry == null;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCountry = null;
                              });
                            },
                            child: Chip(
                              label: Text(
                                'All',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : context.surfaceColor,
                            ),
                          ),
                        );
                      }

                      final country = countries.elementAt(index - 1);
                      final isSelected = _selectedCountry == country;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;
                            });
                          },
                          child: Chip(
                            label: Text(
                              country,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : context.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: isSelected
                                ? AppColors.primary
                                : context.surfaceColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Loading State
            if (destinationState.status == DestinationStatus.loading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // Error State
            if (destinationState.status == DestinationStatus.error)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 80,
                          color: context.textTertiary.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Destinations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          destinationState.errorMessage ?? 'Please try again',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(destinationViewModelProvider.notifier)
                                .getAllDestinations();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Empty State
            if (destinationState.status == DestinationStatus.loaded &&
                filteredDestinations.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          size: 80,
                          color: context.textTertiary.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Destinations Found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Try a different search'
                              : 'Start exploring amazing places',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Destination Cards - Grid View
            if (destinationState.status == DestinationStatus.loaded &&
                filteredDestinations.isNotEmpty &&
                _isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final destination = filteredDestinations[index];
                    return _DestinationGridCard(
                      destination: destination,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DestinationDetailPage(destination: destination),
                          ),
                        );
                      },
                    );
                  }, childCount: filteredDestinations.length),
                ),
              ),

            // Destination Cards - List View
            if (destinationState.status == DestinationStatus.loaded &&
                filteredDestinations.isNotEmpty &&
                !_isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final destination = filteredDestinations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _DestinationListCard(
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
                  }, childCount: filteredDestinations.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _DestinationGridCard extends StatelessWidget {
  final GlobalDestinationEntity destination;
  final VoidCallback onTap;

  const _DestinationGridCard({required this.destination, required this.onTap});

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
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: destination.primaryImage != null
                    ? Image.network(
                        destination.primaryImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.place_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.place_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: context.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.country,
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
                    const Spacer(),
                    if (destination.attractions?.isNotEmpty ?? false)
                      Row(
                        children: [
                          Icon(
                            Icons.attractions_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${destination.attractions!.length} attractions',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationListCard extends StatelessWidget {
  final GlobalDestinationEntity destination;
  final VoidCallback onTap;

  const _DestinationListCard({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.softShadow,
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 120,
                child: destination.primaryImage != null
                    ? Image.network(
                        destination.primaryImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.place_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.place_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: context.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination.country,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (destination.attractions?.isNotEmpty ?? false) ...[
                          Icon(
                            Icons.attractions_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${destination.attractions!.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (destination.bestTimeToVisit != null) ...[
                          Icon(
                            Icons.wb_sunny_outlined,
                            size: 14,
                            color: AppColors.accent2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            destination.bestTimeToVisit!,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: context.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/widgets/app_button.dart';
import 'package:tripmates/core/widgets/app_card.dart';
import 'package:tripmates/core/widgets/app_loading.dart';
import 'package:tripmates/app/theme/app_colors.dart';

/// Widget to display a single trip card with basic information
class TripCard extends ConsumerWidget {
  final String tripId;
  final String destination;
  final String title;
  final String? imageUrl;
  final double? price;
  final int members;
  final double rating;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TripCard({
    super.key,
    required this.tripId,
    required this.destination,
    required this.title,
    this.imageUrl,
    this.price,
    required this.members,
    required this.rating,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Image
          if (imageUrl != null && imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (imageUrl == null || imageUrl!.isEmpty)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.luggage_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 12),

          // Trip Title
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Destination
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  destination,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price and Members Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              if (price != null)
                Text(
                  'NPR $price',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

              // Members Count
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 16),
                  const SizedBox(width: 4),
                  Text('$members members'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Rating
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text('$rating'),
              const SizedBox(width: 8),
              if (onDelete != null) const Spacer(),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget to display trip filters
class TripFilterChips extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const TripFilterChips({super.key, required this.onFilterChanged});

  @override
  State<TripFilterChips> createState() => _TripFilterChipsState();
}

class _TripFilterChipsState extends State<TripFilterChips> {
  final Map<String, bool> filters = {
    'Budget': false,
    'Difficulty': false,
    'Duration': false,
    'Activities': false,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: filters.entries.map((entry) {
        return FilterChip(
          label: Text(entry.key),
          selected: entry.value,
          onSelected: (selected) {
            setState(() {
              filters[entry.key] = selected;
              widget.onFilterChanged(filters);
            });
          },
        );
      }).toList(),
    );
  }
}

/// Loading widget for trip list
class TripListLoading extends StatelessWidget {
  const TripListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: AppLoadingSpinner());
  }
}

/// Empty state widget for trip list
class TripEmptyState extends StatelessWidget {
  final VoidCallback onCreateTrip;

  const TripEmptyState({super.key, required this.onCreateTrip});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.luggage_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No trips found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first trip to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          AppElevatedButton(onPressed: onCreateTrip, label: 'Create Trip'),
        ],
      ),
    );
  }
}

/// Trip search bar widget
class TripSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final Function(String) onDestinationFilter;

  const TripSearchBar({
    super.key,
    required this.onSearch,
    required this.onDestinationFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search trips...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () {
              _showDestinationFilter(context, onDestinationFilter);
            },
          ),
        ],
      ),
    );
  }
}

// Helper function to show destination filter bottom sheet
void _showDestinationFilter(
  BuildContext context,
  Function(String) onDestinationSelected,
) {
  final popularDestinations = [
    'Paris, France',
    'Tokyo, Japan',
    'New York, USA',
    'London, UK',
    'Dubai, UAE',
    'Barcelona, Spain',
    'Rome, Italy',
    'Bangkok, Thailand',
    'Sydney, Australia',
    'Amsterdam, Netherlands',
  ];

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: EdgeInsets.all(20),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by Destination',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: popularDestinations.length,
              itemBuilder: (context, index) {
                final destination = popularDestinations[index];
                return ListTile(
                  leading: Icon(Icons.location_on, color: AppColors.primary),
                  title: Text(destination),
                  onTap: () {
                    Navigator.pop(context);
                    onDestinationSelected(destination);
                  },
                );
              },
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDestinationSelected(''); // Clear filter
              },
              label: 'Clear Filter',
            ),
          ),
        ],
      ),
    ),
  );
}

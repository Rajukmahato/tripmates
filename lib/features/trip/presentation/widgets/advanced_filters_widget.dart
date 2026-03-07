import 'package:flutter/material.dart';

class TripFilters {
  final double? minDistance;
  final double? maxDistance;
  final int? minDuration;
  final int? maxDuration;
  final String? difficulty;
  final String? season;
  final String? fitnessLevel;
  final List<String>? selectedActivities;

  const TripFilters({
    this.minDistance,
    this.maxDistance,
    this.minDuration,
    this.maxDuration,
    this.difficulty,
    this.season,
    this.fitnessLevel,
    this.selectedActivities,
  });

  bool get isEmpty =>
      minDistance == null &&
      maxDistance == null &&
      minDuration == null &&
      maxDuration == null &&
      difficulty == null &&
      season == null &&
      fitnessLevel == null &&
      (selectedActivities == null || selectedActivities!.isEmpty);

  TripFilters copyWith({
    double? minDistance,
    double? maxDistance,
    int? minDuration,
    int? maxDuration,
    String? difficulty,
    String? season,
    String? fitnessLevel,
    List<String>? selectedActivities,
  }) {
    return TripFilters(
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      difficulty: difficulty ?? this.difficulty,
      season: season ?? this.season,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      selectedActivities: selectedActivities ?? this.selectedActivities,
    );
  }

  void reset() {}
}

class AdvancedFiltersDialog extends StatefulWidget {
  final TripFilters initialFilters;
  final Function(TripFilters) onApply;

  const AdvancedFiltersDialog({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<AdvancedFiltersDialog> createState() => _AdvancedFiltersDialogState();
}

class _AdvancedFiltersDialogState extends State<AdvancedFiltersDialog> {
  late TripFilters _filters;
  late RangeValues _distanceRange;
  late RangeValues _durationRange;

  final List<String> _difficulties = [
    'Easy',
    'Moderate',
    'Challenging',
    'Expert',
  ];
  final List<String> _seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
  final List<String> _fitnessLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];
  final List<String> _activities = [
    'Hiking',
    'Camping',
    'Rock Climbing',
    'Water Sports',
    'Photography',
    'Cycling',
    'Skiing',
    'Beach',
    'Cultural',
    'Adventure',
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _distanceRange = RangeValues(
      _filters.minDistance ?? 0,
      _filters.maxDistance ?? 500,
    );
    _durationRange = RangeValues(
      (_filters.minDuration ?? 1).toDouble(),
      (_filters.maxDuration ?? 30).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Filters'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filters = const TripFilters();
                _distanceRange = const RangeValues(0, 500);
                _durationRange = const RangeValues(1, 30);
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Distance Filter
          _buildSectionTitle('Distance (km)'),
          RangeSlider(
            values: _distanceRange,
            min: 0,
            max: 500,
            divisions: 100,
            labels: RangeLabels(
              '${_distanceRange.start.toStringAsFixed(0)}km',
              '${_distanceRange.end.toStringAsFixed(0)}km',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _distanceRange = values;
                _filters = _filters.copyWith(
                  minDistance: values.start,
                  maxDistance: values.end,
                );
              });
            },
          ),
          const SizedBox(height: 24),

          // Duration Filter
          _buildSectionTitle('Duration (hours)'),
          RangeSlider(
            values: _durationRange,
            min: 1,
            max: 30,
            divisions: 29,
            labels: RangeLabels(
              '${_durationRange.start.toInt()}h',
              '${_durationRange.end.toInt()}h',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _durationRange = values;
                _filters = _filters.copyWith(
                  minDuration: values.start.toInt(),
                  maxDuration: values.end.toInt(),
                );
              });
            },
          ),
          const SizedBox(height: 24),

          // Difficulty Filter
          _buildSectionTitle('Difficulty'),
          Wrap(
            spacing: 8,
            children: _difficulties.map((difficulty) {
              final isSelected = _filters.difficulty == difficulty;
              return FilterChip(
                label: Text(difficulty),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      difficulty: selected ? difficulty : null,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Season Filter
          _buildSectionTitle('Best Season'),
          Wrap(
            spacing: 8,
            children: _seasons.map((season) {
              final isSelected = _filters.season == season;
              return FilterChip(
                label: Text(season),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      season: selected ? season : null,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Fitness Level Filter
          _buildSectionTitle('Fitness Level Required'),
          Wrap(
            spacing: 8,
            children: _fitnessLevels.map((level) {
              final isSelected = _filters.fitnessLevel == level;
              return FilterChip(
                label: Text(level),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      fitnessLevel: selected ? level : null,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Activities Filter
          _buildSectionTitle('Activities'),
          Wrap(
            spacing: 8,
            children: _activities.map((activity) {
              final isSelected =
                  _filters.selectedActivities?.contains(activity) ?? false;
              return FilterChip(
                label: Text(activity),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final activities = List<String>.from(
                      _filters.selectedActivities ?? [],
                    );
                    if (selected) {
                      activities.add(activity);
                    } else {
                      activities.remove(activity);
                    }
                    _filters = _filters.copyWith(
                      selectedActivities: activities.isEmpty
                          ? null
                          : activities,
                    );
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Apply Button
          ElevatedButton.icon(
            onPressed: () {
              widget.onApply(_filters);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.done),
            label: const Text('Apply Filters'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

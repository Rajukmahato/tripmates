import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/presentation/view_model/trip_viewmodel.dart';
import 'package:tripmates/features/trip/presentation/state/trip_state.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/features/category/presentation/view_model/category_viewmodel.dart';

class MultiSectionTripForm extends ConsumerStatefulWidget {
  const MultiSectionTripForm({super.key});

  @override
  ConsumerState<MultiSectionTripForm> createState() =>
      _MultiSectionTripFormState();
}

class _MultiSectionTripFormState extends ConsumerState<MultiSectionTripForm> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();

  // Section 1: Basic Info
  final _tripNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TripStatus _status = TripStatus.planned;
  String? _selectedCategoryId;
  File? _selectedImage;

  // Section 2: Trip Details
  String? _difficulty;
  String? _fitnessLevel;
  double? _distanceMin;
  double? _distanceMax;
  int? _elevationMin;
  int? _elevationMax;
  int? _durationMin;
  int? _durationMax;

  // Section 3: Activities & Season
  final List<String> _selectedActivities = [];
  String? _bestSeason;
  final List<String> _selectedMonths = [];

  // Section 4: Inclusions & Details
  String? _meals;
  String? _accommodation;
  final _highlightsController = TextEditingController();
  final _inclusionsController = TextEditingController();
  final _exclusionsController = TextEditingController();
  final _skillLevelController = TextEditingController();
  final _physicalDemandController = TextEditingController();

  final List<String> _difficulties = [
    'Easy',
    'Moderate',
    'Challenging',
    'Expert',
  ];
  final List<String> _seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final List<String> _allActivities = [
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
    Future.microtask(() {
      ref.read(categoryViewModelProvider.notifier).getAllCategories();
    });
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _descriptionController.dispose();
    _destinationController.dispose();
    _highlightsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _endDate ??
          (_startDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _submitTrip() async {
    if (_tripNameController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Get user ID from current session using async provider
    final currentSession = await ref.read(currentUserSessionProvider.future);
    final userId = currentSession?['userId'] as String? ?? '';

    ref
        .read(tripViewModelProvider.notifier)
        .createTrip(
          tripName: _tripNameController.text,
          destination: _destinationController.text,
          startDate: _startDate!,
          endDate: _endDate!,
          status: _status,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          category: _selectedCategoryId,
          media: _selectedImage?.path,
          userId: userId,
          // Web parity fields
          budget: _budgetController.text.isNotEmpty
              ? double.tryParse(_budgetController.text)
              : null,
          distanceMin: _distanceMin,
          distanceMax: _distanceMax,
          elevationMin: _elevationMin,
          elevationMax: _elevationMax,
          durationMinHours: _durationMin,
          durationMaxHours: _durationMax,
          difficultyLevel: _difficulty,
          fitnessLevel: _fitnessLevel,
          physicalDemand: _physicalDemandController.text.isNotEmpty
              ? _physicalDemandController.text
              : null,
          skillLevelRequired: _skillLevelController.text.isNotEmpty
              ? _skillLevelController.text
              : null,
          bestSeason: _bestSeason,
          bestMonths: _selectedMonths.isNotEmpty ? _selectedMonths : null,
          mealsIncluded: _meals,
          accommodationType: _accommodation,
          highlights: _highlightsController.text.isNotEmpty
              ? [_highlightsController.text]
              : null,
          inclusions: _inclusionsController.text.isNotEmpty
              ? _inclusionsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList()
              : null,
          exclusions: _exclusionsController.text.isNotEmpty
              ? _exclusionsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList()
              : null,
          activities: _selectedActivities.isNotEmpty
              ? _selectedActivities
              : null,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryViewModelProvider).categories;
    final tripState = ref.watch(tripViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Trip'), elevation: 0),
      body: tripState.status == TripStateStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  _submitTrip();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                } else {
                  Navigator.pop(context);
                }
              },
              steps: [
                // Step 1: Basic Information
                Step(
                  title: const Text('Basic Information'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _tripNameController,
                          decoration: const InputDecoration(
                            labelText: 'Trip Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                            labelText: 'Destination *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        // Date Pickers
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _selectStartDate,
                                child: Text(
                                  _startDate == null
                                      ? 'Select Start Date *'
                                      : 'Start: ${_startDate.toString().split(' ')[0]}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _selectEndDate,
                                child: Text(
                                  _endDate == null
                                      ? 'Select End Date *'
                                      : 'End: ${_endDate.toString().split(' ')[0]}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Budget
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Budget (USD)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedCategoryId,
                          items: categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat.categoryId,
                                  child: Text(cat.categoryName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCategoryId = value),
                        ),
                        const SizedBox(height: 16),
                        // Image Picker
                        _selectedImage != null
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImage!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _pickImage,
                                    child: const Text('Change Image'),
                                  ),
                                ],
                              )
                            : ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text('Pick Image'),
                              ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                ),

                // Step 2: Trip Details
                Step(
                  title: const Text('Trip Details'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Difficulty
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Difficulty Level',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _difficulty,
                          items: _difficulties
                              .map(
                                (d) =>
                                    DropdownMenuItem(value: d, child: Text(d)),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _difficulty = value),
                        ),
                        const SizedBox(height: 16),
                        // Fitness Level
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Fitness Level Required',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _fitnessLevel,
                          items:
                              ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => _fitnessLevel = value),
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 1,
                ),

                // Step 3: Activities & Season
                Step(
                  title: const Text('Activities & Season'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _allActivities
                              .map(
                                (activity) => FilterChip(
                                  label: Text(activity),
                                  selected: _selectedActivities.contains(
                                    activity,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedActivities.add(activity);
                                      } else {
                                        _selectedActivities.remove(activity);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        // Best Season
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Best Season',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _bestSeason,
                          items: _seasons
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _bestSeason = value),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Best Months',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: _months
                              .map(
                                (month) => FilterChip(
                                  label: Text(month.substring(0, 3)),
                                  selected: _selectedMonths.contains(month),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedMonths.add(month);
                                      } else {
                                        _selectedMonths.remove(month);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 2,
                ),

                // Step 4: Inclusions & Details
                Step(
                  title: const Text('Inclusions & Details'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meals
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Meals Included',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _meals,
                          items:
                              [
                                    'All',
                                    'Breakfast & Lunch',
                                    'Breakfast Only',
                                    'None',
                                  ]
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) => setState(() => _meals = value),
                        ),
                        const SizedBox(height: 16),
                        // Accommodation
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Accommodation Type',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _accommodation,
                          items:
                              [
                                    'Hotels',
                                    'Hostels',
                                    'Camping',
                                    'Guesthouses',
                                    'Luxury Resorts',
                                  ]
                                  .map(
                                    (a) => DropdownMenuItem(
                                      value: a,
                                      child: Text(a),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => _accommodation = value),
                        ),
                        const SizedBox(height: 16),
                        // Highlights
                        TextFormField(
                          controller: _highlightsController,
                          decoration: const InputDecoration(
                            labelText: 'Trip Highlights',
                            border: OutlineInputBorder(),
                            hintText: 'Separate with commas',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        // Trip Status
                        DropdownButtonFormField<TripStatus>(
                          decoration: const InputDecoration(
                            labelText: 'Trip Status',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _status,
                          items: TripStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status.toString().split('.').last,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _status = value!),
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 3,
                ),
              ],
            ),
    );
  }
}

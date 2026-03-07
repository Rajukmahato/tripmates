import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/presentation/state/trip_state.dart';
import 'package:tripmates/features/trip/presentation/view_model/trip_viewmodel.dart';
import 'package:tripmates/features/category/presentation/view_model/category_viewmodel.dart';
import 'package:tripmates/features/global_destinations/presentation/view_model/destination_viewmodel.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';

class AddTripPage extends ConsumerStatefulWidget {
  const AddTripPage({super.key});

  @override
  ConsumerState<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends ConsumerState<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _distanceMinController = TextEditingController();
  final _distanceMaxController = TextEditingController();
  final _durationMinController = TextEditingController();
  final _durationMaxController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _accommodationTypeController = TextEditingController();
  final _highlightsController = TextEditingController();
  final _groupSizeMinController = TextEditingController();
  final _groupSizeMaxController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  final TripStatus _status = TripStatus.planned;
  String? _selectedCategoryName;
  GlobalDestinationEntity? _selectedDestination;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Optional fields
  String? _distanceUnit = 'km';
  String? _travelType;
  String? _difficultyLevel;
  String? _physicalDemand;
  String? _skillLevelRequired;
  String? _bestSeason;
  bool _guideIncluded = false;
  bool _mealsIncluded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryViewModelProvider.notifier).getAllCategories();
      ref.read(destinationViewModelProvider.notifier).getAllDestinations();
    });
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _distanceMinController.dispose();
    _distanceMaxController.dispose();
    _durationMinController.dispose();
    _durationMaxController.dispose();
    _activitiesController.dispose();
    _accommodationTypeController.dispose();
    _highlightsController.dispose();
    _groupSizeMinController.dispose();
    _groupSizeMaxController.dispose();
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

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
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
        ).showSnackBar(SnackBar(content: Text('Error taking picture: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textTertiary.withAlpha(77),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ImageSourceOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ImageSourceOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _takePicture();
                        },
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: context.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select start date')));
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select end date')));
      return;
    }

    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId();

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    print('🔵 [AddTripPage] Create Trip button clicked');
    print('   User ID: $userId');
    print('   Trip Name: ${_tripNameController.text.trim()}');
    print('   Destination: ${_selectedDestination?.displayName ?? _destinationController.text.trim()}');

    ref
        .read(tripViewModelProvider.notifier)
        .createTrip(
          tripName: _tripNameController.text.trim(),
          destination:
              _selectedDestination?.displayName ??
              _destinationController.text.trim(),
          startDate: _startDate!,
          endDate: _endDate!,
          status: _status,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategoryName,
          media: _selectedImage?.path,
          userId: userId,
          // Required backend fields
          travelType: _travelType ?? 'leisure',
          groupSizeMin: _groupSizeMinController.text.isEmpty
              ? 1
              : int.tryParse(_groupSizeMinController.text) ?? 1,
          groupSizeMax: _groupSizeMaxController.text.isEmpty
              ? 10
              : int.tryParse(_groupSizeMaxController.text) ?? 10,
          // Optional fields from web parity
          budget: _budgetController.text.isEmpty
              ? 0.0
              : double.tryParse(_budgetController.text) ?? 0.0,
          distanceMin: _distanceMinController.text.isEmpty
              ? null
              : double.tryParse(_distanceMinController.text),
          distanceMax: _distanceMaxController.text.isEmpty
              ? null
              : double.tryParse(_distanceMaxController.text),
          distanceUnit: _distanceUnit,
          durationMinHours: _durationMinController.text.isEmpty
              ? null
              : int.tryParse(_durationMinController.text),
          durationMaxHours: _durationMaxController.text.isEmpty
              ? null
              : int.tryParse(_durationMaxController.text),
          difficultyLevel: _difficultyLevel,
          physicalDemand: _physicalDemand,
          skillLevelRequired: _skillLevelRequired,
          bestSeason: _bestSeason,
          activities: _activitiesController.text.isEmpty
              ? null
              : _activitiesController.text
                    .split(',')
                    .map((a) => a.trim())
                    .where((a) => a.isNotEmpty)
                    .toList(),
          highlights: _highlightsController.text.isEmpty
              ? null
              : _highlightsController.text
                    .split(',')
                    .map((h) => h.trim())
                    .where((h) => h.isNotEmpty)
                    .toList(),
          accommodationType: _accommodationTypeController.text.isEmpty
              ? null
              : _accommodationTypeController.text,
          guideIncluded: _guideIncluded ? true : null,
          mealsIncluded: _mealsIncluded ? 'true' : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripViewModelProvider);
    final categoryState = ref.watch(categoryViewModelProvider);

    ref.listen<TripState>(tripViewModelProvider, (previous, next) {
      print('🔵 [AddTripPage] State changed from ${previous?.status} to ${next.status}');
      if (next.status == TripStateStatus.created) {
        print('✅ [AddTripPage] Trip created - showing success snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully!')),
        );
        Navigator.pop(context);
      } else if (next.status == TripStateStatus.error) {
        print('❌ [AddTripPage] Error creating trip: ${next.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Error creating trip')),
        );
      }
    });

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create New Trip',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: context.softShadow,
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Add Trip Photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to upload',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.textTertiary,
                              ),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: _showImageSourceDialog,
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Trip Name
              Text(
                'Trip Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tripNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Bali Adventure',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter trip name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Destination
              Text(
                'Destination',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, child) {
                  final destinationState = ref.watch(
                    destinationViewModelProvider,
                  );
                  final destinations = destinationState.destinations;

                  if (destinations.isEmpty) {
                    return TextFormField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        hintText:
                            'Enter destination or wait for list to load...',
                        filled: true,
                        fillColor: context.surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.location_on_rounded),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a destination';
                        }
                        return null;
                      },
                    );
                  }

                  // Filter destinations based on search text
                  final searchText = _destinationController.text.toLowerCase();
                  final filteredDestinations = destinations
                      .where(
                        (d) =>
                            d.name.toLowerCase().contains(searchText) ||
                            d.country.toLowerCase().contains(searchText),
                      )
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          hintText: 'Search or type destination',
                          filled: true,
                          fillColor: context.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.location_on_rounded),
                          suffixIcon: _selectedDestination != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDestination = null;
                                      _destinationController.clear();
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            // Clear selection if user is typing custom text
                            if (value.isNotEmpty &&
                                _selectedDestination != null &&
                                value != _selectedDestination!.name) {
                              _selectedDestination = null;
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a destination';
                          }
                          return null;
                        },
                      ),
                      // Show suggestions if text is entered and destinations match
                      if (searchText.isNotEmpty &&
                          filteredDestinations.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.dividerColor),
                          ),
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shrinkWrap: true,
                            itemCount: filteredDestinations.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: context.dividerColor),
                            itemBuilder: (context, index) {
                              final dest = filteredDestinations[index];
                              final isSelected =
                                  _selectedDestination?.id == dest.id;
                              return Container(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : null,
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    dest.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : context.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    dest.country,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedDestination = dest;
                                      _destinationController.text = dest.name;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: context.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: context.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _startDate != null
                                        ? context.textPrimary
                                        : context.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: context.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: context.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _endDate != null
                                        ? context.textPrimary
                                        : context.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Category
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryName,
                    hint: const Text('Select category'),
                    isExpanded: true,
                    items: categoryState.categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.categoryName,
                            child: Row(
                              children: [
                                Text(category.icon ?? '🏖️'),
                                const SizedBox(width: 12),
                                Text(category.categoryName),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryName = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Budget
              Text(
                'Budget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Trip budget (e.g., 5000)',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.money_rounded),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Travel Type
              Text(
                'Travel Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _travelType,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Select travel type',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.people_rounded),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'adventure',
                    child: Text('Adventure'),
                  ),
                  DropdownMenuItem(value: 'leisure', child: Text('Leisure')),
                  DropdownMenuItem(value: 'business', child: Text('Business')),
                  DropdownMenuItem(
                    value: 'backpacking',
                    child: Text('Backpacking'),
                  ),
                  DropdownMenuItem(value: 'cultural', child: Text('Cultural')),
                ],
                onChanged: (value) {
                  setState(() {
                    _travelType = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Group Size Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Min Group Size',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _groupSizeMinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '1',
                            filled: true,
                            fillColor: context.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Group Size',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _groupSizeMaxController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '10',
                            filled: true,
                            fillColor: context.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                'Description (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us about your trip...',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 32),

              // Optional Fields Section Header
              Text(
                'Additional Details (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              // Distance Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Min Distance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _distanceMinController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            filled: true,
                            fillColor: context.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Distance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _distanceMaxController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            filled: true,
                            fillColor: context.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Distance Unit
              DropdownButtonFormField<String>(
                initialValue: _distanceUnit,
                decoration: InputDecoration(
                  labelText: 'Distance Unit',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: ['km', 'miles'].map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _distanceUnit = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Duration Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Min Duration (hours)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durationMinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            filled: true,
                            fillColor: context.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Duration (hours)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durationMaxController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            filled: true,
                            fillColor: context.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Difficulty Level
              DropdownButtonFormField<String>(
                initialValue: _difficultyLevel,
                decoration: InputDecoration(
                  labelText: 'Difficulty Level',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: ['Easy', 'Moderate', 'Hard', 'Expert', 'Extreme'].map((
                  level,
                ) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _difficultyLevel = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Physical Demand
              DropdownButtonFormField<String>(
                initialValue: _physicalDemand,
                decoration: InputDecoration(
                  labelText: 'Physical Demand',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: ['Light', 'Moderate', 'Strenuous', 'Very Strenuous'].map(
                  (demand) {
                    return DropdownMenuItem(value: demand, child: Text(demand));
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _physicalDemand = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Skill Level Required
              DropdownButtonFormField<String>(
                initialValue: _skillLevelRequired,
                decoration: InputDecoration(
                  labelText: 'Skill Level Required',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: ['Beginner', 'Intermediate', 'Advanced', 'Expert'].map((
                  level,
                ) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _skillLevelRequired = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Best Season
              DropdownButtonFormField<String>(
                initialValue: _bestSeason,
                decoration: InputDecoration(
                  labelText: 'Best Season',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: ['Spring', 'Summer', 'Fall', 'Winter', 'Year-round'].map(
                  (season) {
                    return DropdownMenuItem(value: season, child: Text(season));
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _bestSeason = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Activities
              Text(
                'Activities (comma-separated)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _activitiesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g., Hiking, Photography, Camping',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 20),

              // Accommodation Type
              Text(
                'Accommodation Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accommodationTypeController,
                decoration: InputDecoration(
                  hintText: 'e.g., Hotels, Hostels, Camps',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Highlights
              Text(
                'Highlights (comma-separated)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _highlightsController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g., Mountain Views, Local Culture, Adventure',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 20),

              // Guide & Meals Toggles
              Row(
                children: [
                  Expanded(
                    child: _ToggleField(
                      label: 'Guide Included',
                      value: _guideIncluded,
                      onChanged: (value) {
                        setState(() {
                          _guideIncluded = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToggleField(
                      label: 'Meals Included',
                      value: _mealsIncluded,
                      onChanged: (value) {
                        setState(() {
                          _mealsIncluded = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.buttonShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: tripState.status == TripStateStatus.loading
                        ? null
                        : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: tripState.status == TripStateStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Trip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.softShadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

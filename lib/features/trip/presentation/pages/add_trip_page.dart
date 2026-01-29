import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/presentation/state/trip_state.dart';
import 'package:tripmates/features/trip/presentation/view_model/trip_viewmodel.dart';
import 'package:tripmates/features/category/presentation/view_model/category_viewmodel.dart';

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

  DateTime? _startDate;
  DateTime? _endDate;
  TripStatus _status = TripStatus.planned;
  String? _selectedCategoryId;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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
    _destinationController.dispose();
    _descriptionController.dispose();
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

    ref
        .read(tripViewModelProvider.notifier)
        .createTrip(
          tripName: _tripNameController.text.trim(),
          destination: _destinationController.text.trim(),
          startDate: _startDate!,
          endDate: _endDate!,
          status: _status,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategoryId,
          media: _selectedImage?.path,
          userId: userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripViewModelProvider);
    final categoryState = ref.watch(categoryViewModelProvider);

    ref.listen<TripState>(tripViewModelProvider, (previous, next) {
      if (next.status == TripStateStatus.created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully!')),
        );
        Navigator.pop(context);
      } else if (next.status == TripStateStatus.error) {
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
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: 'e.g., Bali, Indonesia',
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter destination';
                  }
                  return null;
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
                    value: _selectedCategoryId,
                    hint: const Text('Select category'),
                    isExpanded: true,
                    items: categoryState.categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.categoryId,
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
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status
              Text(
                'Trip Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatusOption(
                      label: 'Planned',
                      isSelected: _status == TripStatus.planned,
                      onTap: () => setState(() => _status = TripStatus.planned),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusOption(
                      label: 'Ongoing',
                      isSelected: _status == TripStatus.ongoing,
                      onTap: () => setState(() => _status = TripStatus.ongoing),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusOption(
                      label: 'Completed',
                      isSelected: _status == TripStatus.completed,
                      onTap: () =>
                          setState(() => _status = TripStatus.completed),
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

class _StatusOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/presentation/state/destination_state.dart';
import 'package:tripmates/features/global_destinations/presentation/view_model/destination_viewmodel.dart';

class AdminDestinationFormPage extends ConsumerStatefulWidget {
  final GlobalDestinationEntity? destination;

  const AdminDestinationFormPage({super.key, this.destination});

  @override
  ConsumerState<AdminDestinationFormPage> createState() =>
      _AdminDestinationFormPageState();
}

class _AdminDestinationFormPageState
    extends ConsumerState<AdminDestinationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _countryController;
  late TextEditingController _descriptionController;
  late TextEditingController _attractionsController;
  late TextEditingController _imagesController;
  late TextEditingController _travelTipsController;
  late TextEditingController _climateController;
  late TextEditingController _bestTimeController;
  late TextEditingController _activitiesController;
  late TextEditingController _currencyController;
  late TextEditingController _languageController;
  late TextEditingController _timezoneController;

  bool _isLoading = false;
  bool get _isEditMode => widget.destination != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.destination?.name ?? '',
    );
    _countryController = TextEditingController(
      text: widget.destination?.country ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.destination?.description ?? '',
    );
    _attractionsController = TextEditingController(
      text: widget.destination?.attractions?.join(', ') ?? '',
    );
    _imagesController = TextEditingController(
      text: widget.destination?.images?.join(', ') ?? '',
    );
    _travelTipsController = TextEditingController(
      text: widget.destination?.travelTips?.join(', ') ?? '',
    );
    _climateController = TextEditingController(
      text: widget.destination?.climate ?? '',
    );
    _bestTimeController = TextEditingController(
      text: widget.destination?.bestTimeToVisit ?? '',
    );
    _activitiesController = TextEditingController(
      text: widget.destination?.popularActivities?.join(', ') ?? '',
    );
    _currencyController = TextEditingController(
      text: widget.destination?.currency ?? '',
    );
    _languageController = TextEditingController(
      text: widget.destination?.language ?? '',
    );
    _timezoneController = TextEditingController(
      text: widget.destination?.timezone ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _attractionsController.dispose();
    _imagesController.dispose();
    _travelTipsController.dispose();
    _climateController.dispose();
    _bestTimeController.dispose();
    _activitiesController.dispose();
    _currencyController.dispose();
    _languageController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _isEditMode ? 'Edit Destination' : 'Add Destination',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        _SectionHeader(title: 'Basic Information'),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _nameController,
                          label: 'Destination Name',
                          icon: Icons.place_rounded,
                          required: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter destination name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _countryController,
                          label: 'Country',
                          icon: Icons.flag_rounded,
                          required: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter country';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.description_outlined,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),

                        // Attractions & Activities Section
                        _SectionHeader(title: 'Attractions & Activities'),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _attractionsController,
                          label: 'Attractions (comma separated)',
                          icon: Icons.attractions_outlined,
                          helperText:
                              'e.g., Eiffel Tower, Louvre Museum, Notre-Dame',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _activitiesController,
                          label: 'Popular Activities (comma separated)',
                          icon: Icons.local_activity_outlined,
                          helperText: 'e.g., Hiking, Sightseeing, Photography',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),

                        // Media Section
                        _SectionHeader(title: 'Media'),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _imagesController,
                          label: 'Image URLs (comma separated)',
                          icon: Icons.image_outlined,
                          helperText: 'Enter full URLs separated by commas',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Travel Information Section
                        _SectionHeader(title: 'Travel Information'),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _travelTipsController,
                          label: 'Travel Tips',
                          icon: Icons.lightbulb_outline_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _climateController,
                          label: 'Climate',
                          icon: Icons.wb_sunny_outlined,
                          helperText: 'e.g., Tropical, Mediterranean, Arid',
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _bestTimeController,
                          label: 'Best Time to Visit',
                          icon: Icons.calendar_month_outlined,
                          helperText: 'e.g., April - October',
                        ),
                        const SizedBox(height: 24),

                        // Additional Details Section
                        _SectionHeader(title: 'Additional Details'),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _currencyController,
                          label: 'Currency',
                          icon: Icons.currency_exchange_rounded,
                          helperText: 'e.g., USD, EUR, JPY',
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _languageController,
                          label: 'Primary Language',
                          icon: Icons.language_rounded,
                          helperText: 'e.g., English, French, Spanish',
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _timezoneController,
                          label: 'Timezone',
                          icon: Icons.access_time_rounded,
                          helperText: 'e.g., UTC+1, GMT-5',
                        ),
                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveDestination,
                            icon: Icon(
                              _isEditMode
                                  ? Icons.save_rounded
                                  : Icons.add_rounded,
                            ),
                            label: Text(
                              _isEditMode
                                  ? 'Update Destination'
                                  : 'Create Destination',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        helperText: helperText,
        helperMaxLines: 2,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: context.surfaceColor,
      ),
      validator: validator,
    );
  }

  Future<void> _saveDestination() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Parse comma-separated lists
    final attractions = _attractionsController.text.trim().isNotEmpty
        ? _attractionsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : null;

    final activities = _activitiesController.text.trim().isNotEmpty
        ? _activitiesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : null;

    final images = _imagesController.text.trim().isNotEmpty
        ? _imagesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : null;

    final travelTips = _travelTipsController.text.trim().isNotEmpty
        ? _travelTipsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : null;

    // Build request data
    final data = {
      'name': _nameController.text.trim(),
      'country': _countryController.text.trim(),
      if (_descriptionController.text.trim().isNotEmpty)
        'description': _descriptionController.text.trim(),
      if (attractions != null) 'attractions': attractions,
      if (images != null) 'images': images,
      if (travelTips != null) 'travelTips': travelTips,
      if (_climateController.text.trim().isNotEmpty)
        'climate': _climateController.text.trim(),
      if (_bestTimeController.text.trim().isNotEmpty)
        'bestTimeToVisit': _bestTimeController.text.trim(),
      if (activities != null) 'popularActivities': activities,
      if (_currencyController.text.trim().isNotEmpty)
        'currency': _currencyController.text.trim(),
      if (_languageController.text.trim().isNotEmpty)
        'language': _languageController.text.trim(),
      if (_timezoneController.text.trim().isNotEmpty)
        'timezone': _timezoneController.text.trim(),
    };

    // Call appropriate action
    if (_isEditMode) {
      await ref
          .read(destinationViewModelProvider.notifier)
          .updateDestination(widget.destination!.id, data);
    } else {
      await ref
          .read(destinationViewModelProvider.notifier)
          .createDestination(data);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      final state = ref.read(destinationViewModelProvider);
      if (state.status == DestinationStatus.created ||
          state.status == DestinationStatus.updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Destination updated successfully'
                  : 'Destination created successfully',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else if (state.status == DestinationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Failed to save destination'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

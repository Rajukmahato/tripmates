import 'package:flutter/material.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';
import 'package:tripmates/features/trip/domain/entities/checklist_item_entity.dart';

class ChecklistItemFormDialog extends StatefulWidget {
  final ChecklistItemEntity? item;

  const ChecklistItemFormDialog({super.key, this.item});

  @override
  State<ChecklistItemFormDialog> createState() =>
      _ChecklistItemFormDialogState();
}

class _ChecklistItemFormDialogState extends State<ChecklistItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late ChecklistCategory _selectedCategory;
  ChecklistPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _selectedCategory = widget.item?.category ?? ChecklistCategory.preparation;
    _selectedPriority = widget.item?.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Text(
                isEditing ? 'Edit Checklist Item' : 'Add Checklist Item',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<ChecklistCategory>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ChecklistCategory.values
                          .map(
                            (category) => DropdownMenuItem<ChecklistCategory>(
                              value: category,
                              child: Text(_categoryLabel(category)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Pack passport',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ChecklistPriority?>(
                      initialValue: _selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'Priority (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<ChecklistPriority?>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...ChecklistPriority.values.map(
                          (priority) => DropdownMenuItem<ChecklistPriority?>(
                            value: priority,
                            child: Text(_priorityLabel(priority)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: context.textTertiary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _onSave,
                          child: Text(isEditing ? 'Update' : 'Save'),
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

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final savedItem = ChecklistItemEntity(
      id: widget.item?.id ?? 'check_${now.microsecondsSinceEpoch}',
      category: _selectedCategory,
      title: _titleController.text.trim(),
      isCompleted: widget.item?.isCompleted ?? false,
      priority: _selectedPriority,
      completedAt: widget.item?.completedAt,
      completedBy: widget.item?.completedBy,
      createdAt: widget.item?.createdAt ?? now,
    );

    Navigator.pop(context, savedItem);
  }

  String _categoryLabel(ChecklistCategory category) {
    switch (category) {
      case ChecklistCategory.documents:
        return 'Documents';
      case ChecklistCategory.packing:
        return 'Packing';
      case ChecklistCategory.health:
        return 'Health';
      case ChecklistCategory.booking:
        return 'Booking';
      case ChecklistCategory.preparation:
        return 'Preparation';
    }
  }

  String _priorityLabel(ChecklistPriority priority) {
    switch (priority) {
      case ChecklistPriority.low:
        return 'Low';
      case ChecklistPriority.medium:
        return 'Medium';
      case ChecklistPriority.high:
        return 'High';
    }
  }
}

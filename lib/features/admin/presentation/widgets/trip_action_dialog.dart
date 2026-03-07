import 'package:flutter/material.dart';
import 'package:tripmates/core/extensions/context_extensions.dart';

/// Dialog for toggling trip status (activate/deactivate)
class TripActionDialog extends StatefulWidget {
  final String tripId;
  final String tripName;
  final bool isActive;
  final Function(bool newStatus) onConfirm;

  const TripActionDialog({
    super.key,
    required this.tripId,
    required this.tripName,
    required this.isActive,
    required this.onConfirm,
  });

  @override
  State<TripActionDialog> createState() => _TripActionDialogState();
}

class _TripActionDialogState extends State<TripActionDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      widget.onConfirm(!widget.isActive);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final newStatus = !widget.isActive;
    final action = newStatus ? 'Activate' : 'Deactivate';
    final message = newStatus
        ? 'Activate trip "${widget.tripName}"?'
        : 'Deactivate trip "${widget.tripName}"?';

    return AlertDialog(
      backgroundColor: context.surfaceColor,
      title: Text(
        '$action Trip',
        style: TextStyle(
          color: context.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: context.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (newStatus ? Colors.green : Colors.orange).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (newStatus ? Colors.green : Colors.orange).withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    newStatus
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_rounded,
                    color: newStatus ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      newStatus
                          ? 'The trip will be visible to users and accepting participants'
                          : 'The trip will be hidden from users and not accepting participants',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: newStatus ? Colors.green : Colors.orange,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(action, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

/// Dialog for featuring/unfeaturing a trip
class FeatureTripDialog extends StatefulWidget {
  final String tripId;
  final String tripName;
  final bool isFeatured;
  final Function(bool featured) onConfirm;

  const FeatureTripDialog({
    super.key,
    required this.tripId,
    required this.tripName,
    required this.isFeatured,
    required this.onConfirm,
  });

  @override
  State<FeatureTripDialog> createState() => _FeatureTripDialogState();
}

class _FeatureTripDialogState extends State<FeatureTripDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      widget.onConfirm(!widget.isFeatured);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final newStatus = !widget.isFeatured;
    final action = newStatus ? 'Feature' : 'Unfeature';
    final message = newStatus
        ? 'Feature trip "${widget.tripName}" on the homepage?'
        : 'Remove trip "${widget.tripName}" from featured?';

    return AlertDialog(
      backgroundColor: context.surfaceColor,
      title: Text(
        '$action Trip',
        style: TextStyle(
          color: context.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: context.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (newStatus ? Colors.blue : Colors.grey).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (newStatus ? Colors.blue : Colors.grey).withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    newStatus ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: newStatus ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      newStatus
                          ? 'Featured trips get more visibility in the app'
                          : 'The trip will no longer appear as featured',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: newStatus ? Colors.blue : Colors.grey,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(action, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

/// Dialog for deleting a trip
class DeleteTripDialog extends StatefulWidget {
  final String tripId;
  final String tripName;
  final Function(String reason) onConfirm;

  const DeleteTripDialog({
    super.key,
    required this.tripId,
    required this.tripName,
    required this.onConfirm,
  });

  @override
  State<DeleteTripDialog> createState() => _DeleteTripDialogState();
}

class _DeleteTripDialogState extends State<DeleteTripDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for deletion')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      widget.onConfirm(_reasonController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.surfaceColor,
      title: Text(
        'Delete Trip',
        style: TextStyle(
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete trip "${widget.tripName}" permanently?',
              style: TextStyle(color: context.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Reason for deletion (required):',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'e.g., Violates guidelines, duplicate, misleading...',
                hintStyle: TextStyle(color: context.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: context.backgroundColor,
                counterStyle: TextStyle(color: context.textTertiary),
              ),
              style: TextStyle(color: context.textPrimary),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleDelete,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

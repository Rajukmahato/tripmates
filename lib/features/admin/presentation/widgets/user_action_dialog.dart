import 'package:flutter/material.dart';
import 'package:tripmates/core/extensions/context_extensions.dart';

/// Dialog for toggling user status (ban/unban)
class UserActionDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final bool currentStatus; // true = active, false = inactive
  final Function(bool newStatus, String? reason) onConfirm;

  const UserActionDialog({
    super.key,
    required this.userId,
    required this.userName,
    required this.currentStatus,
    required this.onConfirm,
  });

  @override
  State<UserActionDialog> createState() => _UserActionDialogState();
}

class _UserActionDialogState extends State<UserActionDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (!widget.currentStatus && _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a reason for banning this user'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call

    if (mounted) {
      widget.onConfirm(!widget.currentStatus, _reasonController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final newStatus = !widget.currentStatus;
    final action = newStatus ? 'Activate' : 'Ban';
    final message = newStatus
        ? 'Activate user ${widget.userName}?'
        : 'Ban user ${widget.userName}?';

    return AlertDialog(
      backgroundColor: context.surfaceColor,
      title: Text(
        '$action User',
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
            if (!newStatus) ...[
              const SizedBox(height: 16),
              Text(
                'Reason for banning (required):',
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
                  hintText:
                      'e.g., Inappropriate behavior, multiple complaints...',
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (!newStatus ? Colors.red : Colors.green).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (!newStatus ? Colors.red : Colors.green).withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    !newStatus
                        ? Icons.warning_rounded
                        : Icons.check_circle_rounded,
                    color: !newStatus ? Colors.red : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      !newStatus
                          ? 'This user will not be able to access the platform'
                          : 'This user will regain access to the platform',
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
            backgroundColor: !newStatus ? Colors.red : Colors.green,
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

/// Dialog for deleting a user
class DeleteUserDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final Function(String reason) onConfirm;

  const DeleteUserDialog({
    super.key,
    required this.userId,
    required this.userName,
    required this.onConfirm,
  });

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  final _reasonController = TextEditingController();
  late FocusNode _focusNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _focusNode.dispose();
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
        'Delete User',
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
              'Delete user ${widget.userName} permanently?',
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
              focusNode: _focusNode,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText:
                    'e.g., Violates terms of service, account takeover...',
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

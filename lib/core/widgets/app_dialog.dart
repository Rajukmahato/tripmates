import 'package:flutter/material.dart';
import 'package:tripmates/app/theme/app_colors.dart';

/// Unified dialog widget for alerts and confirmations
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<AppDialogAction> actions;
  final bool barrierDismissible;
  final EdgeInsetsGeometry? contentPadding;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    required this.actions,
    this.barrierDismissible = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content ?? (message != null ? Text(message!) : null),
      contentPadding:
          contentPadding ?? const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      actions: [
        for (final action in actions)
          TextButton(
            onPressed: action.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: action.isDestructive
                  ? AppColors.error
                  : AppColors.primary,
            ),
            child: Text(action.label),
          ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Show this dialog
  Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => this,
      barrierDismissible: barrierDismissible,
    );
  }
}

/// Action configuration for  dialogs
class AppDialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  AppDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });
}

/// Confirmation dialog builder
class AppConfirmDialogBuilder {
  static AppDialog build({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return AppDialog(
      title: title,
      message: message,
      actions: [
        AppDialogAction(label: cancelLabel, onPressed: onCancel ?? () {}),
        AppDialogAction(
          label: confirmLabel,
          onPressed: onConfirm,
          isDestructive: isDestructive,
        ),
      ],
    );
  }
}

/// Info dialog builder
class AppInfoDialogBuilder {
  static AppDialog build({
    required String title,
    required String message,
    VoidCallback? onOk,
    String okLabel = 'OK',
  }) {
    return AppDialog(
      title: title,
      message: message,
      actions: [AppDialogAction(label: okLabel, onPressed: onOk ?? () {})],
    );
  }
}

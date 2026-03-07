import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage logout dialog state
final logoutDialogProvider = NotifierProvider<LogoutDialogNotifier, bool>(
  LogoutDialogNotifier.new,
);

class LogoutDialogNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Dialog hidden by default
  }

  /// Show the logout dialog
  void show() {
    if (!state) {
      state = true;
      debugPrint('🔴 Logout dialog showing');
    }
  }

  /// Hide the logout dialog
  void hide() {
    state = false;
    debugPrint('✅ Logout dialog hidden');
  }

  /// Check if dialog is currently shown
  bool get isShown => state;
}

import 'package:flutter/material.dart';

/// Context extensions for easy access to theme and MediaQuery properties
extension BuildContextExtensions on BuildContext {
  // Theme colors
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  Color get surfaceColor => Theme.of(this).cardColor;

  Color get primaryColor => Theme.of(this).primaryColor;

  Color get textPrimary =>
      Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;

  Color get textSecondary =>
      Theme.of(this).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
      Colors.grey;

  Color get textTertiary =>
      Theme.of(this).textTheme.bodySmall?.color?.withValues(alpha: 0.4) ??
      Colors.grey.shade400;

  // Card shadow
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // MediaQuery shortcuts
  Size get screenSize => MediaQuery.of(this).size;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  EdgeInsets get padding => MediaQuery.of(this).padding;

  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  // Navigator shortcuts
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> push<T>(Widget page) =>
      Navigator.of(this).push(MaterialPageRoute(builder: (_) => page));

  Future<T?> pushReplacement<T, TO>(Widget page, {TO? result}) => Navigator.of(
    this,
  ).pushReplacement(MaterialPageRoute(builder: (_) => page), result: result);

  void popUntilRoot() => Navigator.of(this).popUntil((route) => route.isFirst);

  // SnackBar helper
  void showSnackBar(
    String message, {
    Duration? duration,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage/storage_service.dart';

// ====================== SHARED PREFERENCES PROVIDER ======================

/// Must be overridden in main.dart before runApp()
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

/// Provides the storage service for SharedPreferences operations
final storageServiceProvider = Provider<StorageService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return StorageService(sharedPreferences);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tripmates/app/app.dart';
import 'package:tripmates/core/services/hive/hive_service.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );
  final hiveService = container.read(hiveServiceProvider);
  await hiveService.init();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
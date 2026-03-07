import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_theme.dart';
import 'package:tripmates/app/theme/theme_provider.dart';
import 'package:tripmates/core/providers/light_sensor_provider.dart';
import 'package:tripmates/features/splash/presentation/pages/splash_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    ref.watch(lightSensorServiceProvider);

    return MaterialApp(
      title: 'TripMates',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

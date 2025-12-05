import 'package:flutter/material.dart';
import 'package:tripmates/screens/onboarding_screen.dart';
import 'package:tripmates/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripMates',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        // Basic theme colors, you can expand this.
        primaryColor: const Color(0xFF2639FF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF4737D6),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

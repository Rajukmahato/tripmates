import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/core/services/deep_link_service.dart';
import 'package:tripmates/features/auth/presentation/pages/reset_password_page.dart';
import 'package:tripmates/features/auth/presentation/state/auth_state.dart';
import 'package:tripmates/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tripmates/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:tripmates/features/onboarding/presentation/pages/onboarding_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _setupDeepLinkListener();
    _checkAuthStatus();
  }

  void _setupDeepLinkListener() {
    DeepLinkHandler.deepLinkStream.listen(
      (deepLink) {
        log('SplashScreen: Received deep link: $deepLink');
        final token = DeepLinkHandler.extractResetToken(deepLink);
        if (token != null && mounted) {
          log('SplashScreen: Reset token extracted: $token');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResetPasswordPage(token: token),
            ),
          );
        }
      },
      onError: (error) {
        log('SplashScreen: Deep link error: $error');
      },
    );
  }

  @override
  void dispose() {
    DeepLinkHandler.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      log('SplashScreen: Starting _checkAuthStatus');

      // Wait for splash display
      await Future.delayed(const Duration(seconds: 3));
      log('SplashScreen: Splash delay completed');

      if (!mounted) {
        log('SplashScreen: Widget not mounted after delay');
        return;
      }

      // Check if user is logged in
      log('SplashScreen: Checking if user is logged in');
      final userSessionService = ref.read(userSessionServiceProvider);
      final isLoggedIn = userSessionService.isLoggedIn();
      log('SplashScreen: isLoggedIn = $isLoggedIn');

      if (isLoggedIn) {
        // User is logged in, fetch current user data
        log('SplashScreen: User is logged in, fetching current user');

        // Add timeout to prevent hanging
        try {
          await ref
              .read(authViewModelProvider.notifier)
              .getCurrentUser()
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  log(
                    'SplashScreen: getCurrentUser timed out after 10 seconds',
                  );
                  throw Exception('Get user timeout');
                },
              );
          log('SplashScreen: getCurrentUser completed successfully');
        } catch (e) {
          log('SplashScreen: Error getting current user: $e');
          // On error or timeout, navigate to onboarding
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
          return;
        }

        if (!mounted) {
          log('SplashScreen: Widget not mounted after getCurrentUser');
          return;
        }

        final authState = ref.read(authViewModelProvider);
        log('SplashScreen: Auth state status = ${authState.status}');

        // Navigate based on auth state
        if (authState.status == AuthStatus.authenticated) {
          log('SplashScreen: Navigating to Dashboard');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        } else {
          // Failed to get user, go to onboarding
          log('SplashScreen: Auth failed, navigating to Onboarding');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      } else {
        // User not logged in, go to onboarding
        log('SplashScreen: User not logged in, navigating to Onboarding');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      }
    } catch (e, stackTrace) {
      log('SplashScreen: Unexpected error in _checkAuthStatus: $e');
      log('SplashScreen: Stack trace: $stackTrace');

      // On any error, navigate to onboarding
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

    final double logoHeight = isTablet ? 260 : 180;
    final double fontSize = isTablet ? 30 : 20;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 90, 50, 231),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: logoHeight),

            const SizedBox(height: 20),
            Text(
              "Your Traveling Partner",
              style: TextStyle(
                fontFamily: "OpenSans Italic",
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

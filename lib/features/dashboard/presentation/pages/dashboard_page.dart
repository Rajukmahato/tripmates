import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/shake_detector.dart';
import '../../../../core/providers/logout_dialog_provider.dart';
import '../../../../core/providers/light_sensor_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/view_model/auth_viewmodel.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../../../chat/presentation/pages/conversation_list_page.dart';
import '../../../trip/presentation/pages/my_trips_page.dart';
import '../../../trip/presentation/pages/add_trip_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;
  ShakeDetector? _shakeDetector;
  bool? _lastShakeEnabled;

  final List<Widget> _screens = const [
    HomeScreen(),
    MyTripsPage(),
    ConversationListPage(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _setShakeEnabled(bool enabled) {
    if (enabled) {
      if (_shakeDetector != null) {
        return;
      }
      _shakeDetector = ShakeDetector(
        onShake: _onShakeDetected,
        shakeCount: 3,
        shakeThreshold: 15.0,
        shakeDuration: const Duration(milliseconds: 1500),
      );
      _shakeDetector?.startListening();
      debugPrint('📳 Shake detector enabled');
      return;
    }

    _shakeDetector?.dispose();
    _shakeDetector = null;
    debugPrint('📳 Shake detector disabled');
  }

  void _onShakeDetected() {
    if (!mounted) return;

    final dialogNotifier = ref.read(logoutDialogProvider.notifier);

    // Only show dialog if not already showing
    if (!dialogNotifier.isShown) {
      dialogNotifier.show();
      _showLogoutDialog();
    }
  }

  void _showLogoutDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text(
          'Triple shake detected! Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(logoutDialogProvider.notifier).hide();
              debugPrint('✅ Logout cancelled');
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              ref.read(logoutDialogProvider.notifier).hide();
              debugPrint('🔓 Logging out...');
              await ref.read(authViewModelProvider.notifier).logout();
              if (mounted) {
                AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeDetector?.dispose();
    super.dispose();
  }

  void _onReportPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTripPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shakeEnabled = ref.watch(shakeToLogoutSwitchProvider);

    if (_lastShakeEnabled != shakeEnabled) {
      _lastShakeEnabled = shakeEnabled;
      _setShakeEnabled(shakeEnabled);
    }

    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        child: FloatingActionButton(
          onPressed: _onReportPressed,
          backgroundColor: context.surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: context.borderColor, width: 1.2),
          ),
          child: Icon(Icons.add_rounded, color: AppColors.primary, size: 34),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Builder(
        builder: (context) => SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: context.borderColor),
              boxShadow: context.softShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.luggage_rounded,
                  label: 'My Trips',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                const SizedBox(width: 60),
                _NavItem(
                  icon: Icons.message_rounded,
                  label: 'Messages',
                  isSelected: _currentIndex == 2,
                  badge: 3,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive horizontal padding based on screen width
    final horizontalPadding = screenWidth < 360 ? 10.0 : 16.0;
    final fontSize = screenWidth < 360 ? 10.0 : 11.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (context.isDarkMode
                    ? AppColors.primary.withAlpha(26)
                    : const Color(0xFFF0F5FF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: context.isDarkMode
                      ? AppColors.primary.withAlpha(77)
                      : const Color(0xFFD8E5FF),
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : context.textSecondary,
                  size: 24,
                ),
                if (badge != null)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '$badge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : context.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

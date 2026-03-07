import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/providers/light_sensor_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/view_model/auth_viewmodel.dart';
import '../../../trip/presentation/view_model/trip_viewmodel.dart';
import '../../../profile/presentation/pages/edit_profile_page.dart';
import '../../../profile/presentation/view_model/profile_viewmodel.dart';
import '../../../profile/presentation/state/profile_state.dart';
import '../../../partner_requests/presentation/pages/partner_requests_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../trip/presentation/pages/my_trips_page.dart';
import '../../../trip/presentation/utils/user_trip_logic.dart';
import '../../../global_destinations/presentation/pages/destinations_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _AutoThemeToggleItem extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _AutoThemeToggleItem({required this.ref});
  @override
  ConsumerState<_AutoThemeToggleItem> createState() =>
      _AutoThemeToggleItemState();
}

class _AutoThemeToggleItemState extends ConsumerState<_AutoThemeToggleItem> {
  @override
  Widget build(BuildContext context) {
    final autoThemeEnabled = ref.watch(autoThemeSwitchProvider);
    final shakeEnabled = ref.watch(shakeToLogoutSwitchProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent1.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.brightness_auto_rounded,
                    color: AppColors.accent1,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Theme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Switch theme based on ambient light',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: autoThemeEnabled,
                  onChanged: (value) {
                    ref
                        .read(autoThemeSwitchProvider.notifier)
                        .setEnabled(value);
                  },
                  activeTrackColor: AppColors.accent1,
                  activeThumbColor: Colors.white,
                ),
              ],
            ),
          ),
          Divider(height: 0.5, color: context.dividerColor),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.vibration_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shake Phone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Triple shake to trigger logout prompt',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: shakeEnabled,
                  onChanged: (value) {
                    ref
                        .read(shakeToLogoutSwitchProvider.notifier)
                        .setEnabled(value);
                  },
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userSessionService = ref.read(userSessionServiceProvider);
      final userId = userSessionService.getCurrentUserId();
      if (userId != null) {
        // Fetch profile from API
        ref.read(profileViewModelProvider.notifier).getProfile(userId);
      }
      ref.read(tripViewModelProvider.notifier).getAllTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final tripState = ref.watch(tripViewModelProvider);
    final currentUserId =
        ref.read(userSessionServiceProvider).getCurrentUserId() ?? '';
    final myTripsSections = getMyTripsSections(tripState.trips, currentUserId);

    final profile = profileState.profile;
    final userName = profile?.fullName ?? 'User';
    final userEmail = profile?.email ?? '';
    final userBio = profile?.bio ?? '';
    final userLocation = profile?.location ?? '';
    final userProfilePicture = profile?.profilePicture;
    final createdTripsCount = tripState.trips
        .where((trip) => trip.createdBy == currentUserId)
        .length;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: profileState.status == ProfileStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: context.isDarkMode
                                ? [
                                    context.surfaceColor,
                                    context.surfaceVariantColor,
                                  ]
                                : const [Color(0xFFFFFFFF), Color(0xFFF2F7FF)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: context.borderColor),
                          boxShadow: context.softShadow,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4AA4FF),
                                    Color(0xFF6A67FF),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x334AA4FF),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: context.surfaceColor,
                                backgroundImage: userProfilePicture != null
                                    ? NetworkImage(userProfilePicture)
                                    : null,
                                child: userProfilePicture == null
                                    ? Text(
                                        userName.isNotEmpty
                                            ? userName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3D6BD6),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 17,
                                color: context.textSecondary,
                              ),
                            ),
                            if (userBio.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  userBio,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                            if (userLocation.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: context.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    userLocation,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _StatItem(
                                    title: 'Planned',
                                    value: '${myTripsSections.planned.length}',
                                    ringColor: const Color(0xFF3B82F6),
                                  ),
                                  _StatItem(
                                    title: 'Ongoing',
                                    value: '${myTripsSections.ongoing.length}',
                                    ringColor: const Color(0xFFF59E0B),
                                  ),
                                  _StatItem(
                                    title: 'Done',
                                    value:
                                        '${myTripsSections.completed.length}',
                                    ringColor: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Menu Items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            onTap: () {
                              AppRoutes.push(context, const EditProfilePage());
                            },
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.luggage_rounded,
                            title: 'My Created Trips',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$createdTripsCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              AppRoutes.push(context, const MyTripsPage());
                            },
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.public_rounded,
                            title: 'Explore Destinations',
                            onTap: () {
                              AppRoutes.push(context, const DestinationsPage());
                            },
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.person_add_outlined,
                            title: 'Partner Requests',
                            onTap: () {
                              AppRoutes.push(
                                context,
                                const PartnerRequestsPage(),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            onTap: () {
                              AppRoutes.push(
                                context,
                                const NotificationsPage(),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.security_rounded,
                            title: 'Privacy & Security',
                            onTap: () {
                              _showPrivacySecurityDialog(context);
                            },
                          ),
                          const SizedBox(height: 12),
                          _ThemeToggleItem(ref: ref),
                          const SizedBox(height: 12),
                          _AutoThemeToggleItem(ref: ref),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            onTap: () {
                              _showHelpSupportDialog(context);
                            },
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'About',
                            onTap: () {
                              _showAboutDialog(context);
                            },
                          ),
                          const SizedBox(height: 24),
                          _MenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            iconColor: AppColors.error,
                            titleColor: AppColors.error,
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Version Info
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary60,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  void _showPrivacySecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.security_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text('Privacy & Security'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _PrivacySetting(
              icon: Icons.lock_outline,
              title: 'Account Privacy',
              subtitle: 'Control who can see your profile',
            ),
            const SizedBox(height: 8),
            _PrivacySetting(
              icon: Icons.visibility_outlined,
              title: 'Trip Visibility',
              subtitle: 'Manage trip sharing settings',
            ),
            const SizedBox(height: 8),
            _PrivacySetting(
              icon: Icons.block_outlined,
              title: 'Blocked Users',
              subtitle: 'View and manage blocked accounts',
            ),
            const SizedBox(height: 16),
            Text(
              'Your data is encrypted and secure. We never share your personal information with third parties.',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'support@tripmate.com',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+977981585197',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'We\'re here to help! Reach out for any questions, feedback, or support needs.',
                style: TextStyle(fontSize: 12, color: context.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.luggage_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text('About TripMates'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'TripMates is your ultimate travel companion app, '
              'helping you plan trips, find travel partners, '
              'and share unforgettable experiences.',
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2026 TripMates. All rights reserved.',
              style: TextStyle(fontSize: 12, color: context.textTertiary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Clear user session
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
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
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color ringColor;

  const _StatItem({
    required this.title,
    required this.value,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.surfaceColor,
            border: Border.all(color: ringColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: ringColor.withAlpha(64),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: context.textSecondary),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
        boxShadow: context.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (iconColor ?? const Color(0xFF5969FF)).withAlpha(24),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? context.textPrimary,
                    ),
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: context.textSecondary50,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleItem extends StatelessWidget {
  final WidgetRef ref;

  const _ThemeToggleItem({required this.ref});

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final autoThemeEnabled = ref.watch(autoThemeSwitchProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: context.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    autoThemeEnabled ? 'Auto' : (isDarkMode ? 'On' : 'Off'),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDarkMode,
              onChanged: autoThemeEnabled
                  ? null
                  : (value) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
              activeTrackColor: AppColors.primary,
              activeThumbColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacySetting extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PrivacySetting({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary.withAlpha(179), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: context.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

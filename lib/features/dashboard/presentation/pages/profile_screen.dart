import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/view_model/auth_viewmodel.dart';
import '../../../trip/presentation/view_model/trip_viewmodel.dart';
import '../../../profile/presentation/pages/edit_profile_page.dart';
import '../../../profile/presentation/view_model/profile_viewmodel.dart';
import '../../../profile/presentation/state/profile_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
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
        // Fetch trips
        ref.read(tripViewModelProvider.notifier).getMyTrips(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final tripState = ref.watch(tripViewModelProvider);

    final profile = profileState.profile;
    final userName = profile?.fullName ?? 'User';
    final userEmail = profile?.email ?? '';
    final userBio = profile?.bio ?? '';
    final userLocation = profile?.location ?? '';
    final userProfilePicture = profile?.profilePicture;

    return Scaffold(
      body: SafeArea(
        child: profileState.status == ProfileStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with gradient background
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Profile Picture
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.black20,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: userProfilePicture != null
                                  ? NetworkImage(userProfilePicture)
                                  : null,
                              child: userProfilePicture == null
                                  ? Text(
                                      userName.isNotEmpty
                                          ? userName[0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),

                          // Bio
                          if (userBio.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                userBio,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],

                          // Location
                          if (userLocation.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  userLocation,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Stats Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  title: 'Planned',
                                  value:
                                      '${tripState.trips.where((t) => t.status.toString().split('.').last == 'planned').length}',
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.white30,
                                ),
                                _StatItem(
                                  title: 'Completed',
                                  value:
                                      '${tripState.trips.where((t) => t.status.toString().split('.').last == 'completed').length}',
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.white30,
                                ),
                                _StatItem(
                                  title: 'Total',
                                  value: '${tripState.trips.length}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
                            icon: Icons.history_rounded,
                            title: 'My Items',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.secondaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.security_rounded,
                            title: 'Privacy & Security',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _ThemeToggleItem(ref: ref),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'About',
                            onTap: () {},
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

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: AppColors.white80)),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
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
                    color: (iconColor ?? AppColors.primary).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
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

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.cardShadow,
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
                    isDarkMode ? 'On' : 'Off',
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
              onChanged: (value) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
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

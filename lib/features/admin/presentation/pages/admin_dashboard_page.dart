import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/core/extensions/context_extensions.dart';
import 'package:tripmates/features/admin/presentation/pages/analytics_page.dart';
import 'package:tripmates/features/admin/presentation/pages/reports_management_page.dart';
import 'package:tripmates/features/admin/presentation/pages/trips_management_page.dart';
import 'package:tripmates/features/admin/presentation/pages/users_management_page.dart';
import 'package:tripmates/features/admin/presentation/viewmodel/admin_viewmodel.dart';
import 'package:tripmates/features/admin/presentation/widgets/admin_stat_card.dart';

/// Main admin dashboard page
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminViewmodelProvider.notifier).loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminViewmodelProvider);
    final stats = adminState.stats;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.textPrimary),
            onPressed: () {
              ref.read(adminViewmodelProvider.notifier).loadAll();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminViewmodelProvider.notifier).loadAll(),
        child: adminState.isStatsLoading && stats == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Stats
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        AdminStatCard(
                          title: 'Total Users',
                          value: '${stats?.totalUsers ?? 0}',
                          subtitle: '${stats?.activeUsers ?? 0} active',
                          icon: Icons.people_rounded,
                          gradient: AppColors.primaryGradient,
                          onTap: () => _navigateToUsers(),
                        ),
                        AdminStatCard(
                          title: 'Total Trips',
                          value: '${stats?.totalTrips ?? 0}',
                          subtitle: '${stats?.activeTrips ?? 0} active',
                          icon: Icons.luggage_rounded,
                          gradient: AppColors.secondaryGradient,
                          onTap: () => _navigateToTrips(),
                        ),
                        AdminStatCard(
                          title: 'Reports',
                          value: '${stats?.totalReports ?? 0}',
                          subtitle: '${stats?.pendingReports ?? 0} pending',
                          icon: Icons.flag_rounded,
                          gradient: AppColors.lostGradient,
                          onTap: () => _navigateToReports(),
                        ),
                        AdminStatCard(
                          title: 'Reviews',
                          value: '${stats?.totalReviews ?? 0}',
                          subtitle: 'All time',
                          icon: Icons.star_rounded,
                          gradient: AppColors.foundGradient,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _ActionCard(
                      icon: Icons.people_rounded,
                      title: 'Manage Users',
                      subtitle: 'View, edit, or deactivate users',
                      onTap: () => _navigateToUsers(),
                    ),
                    const SizedBox(height: 12),

                    _ActionCard(
                      icon: Icons.luggage_rounded,
                      title: 'Manage Trips',
                      subtitle: 'Feature, activate, or delete trips',
                      onTap: () => _navigateToTrips(),
                    ),
                    const SizedBox(height: 12),

                    _ActionCard(
                      icon: Icons.flag_rounded,
                      title: 'Review Reports',
                      subtitle: 'Handle user reports and complaints',
                      onTap: () => _navigateToReports(),
                    ),
                    const SizedBox(height: 12),

                    _ActionCard(
                      icon: Icons.analytics_rounded,
                      title: 'View Analytics',
                      subtitle: 'Detailed statistics and insights',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnalyticsPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Recent Activity Summary
                    if (adminState.pendingReportsCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attention Required',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${adminState.pendingReportsCount} pending reports need review',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => _navigateToReports(),
                              child: const Text('Review'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  void _navigateToUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UsersManagementPage()),
    );
  }

  void _navigateToTrips() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TripsManagementPage()),
    );
  }

  void _navigateToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportsManagementPage()),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

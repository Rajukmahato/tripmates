import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tripmates/core/extensions/context_extensions.dart';
import 'package:tripmates/features/admin/presentation/view_model/analytics_viewmodel.dart';
import 'package:tripmates/features/admin/presentation/view_model/analytics_state.dart';

/// Enhanced Analytics Page with fl_chart integration
class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(analyticsViewModelProvider.notifier).loadAllAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(analyticsViewModelProvider.notifier).refresh(),
        child:
            analyticsState.status == AnalyticsStateStatus.loading &&
                analyticsState.overview == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(analyticsState),
                    const SizedBox(height: 24),

                    // Platform Overview KPI Cards
                    if (analyticsState.overview != null) ...[
                      _buildSectionHeader('Platform Overview'),
                      const SizedBox(height: 12),
                      _buildOverviewCards(analyticsState),
                      const SizedBox(height: 32),
                    ],

                    // User Growth Chart
                    if (analyticsState.userGrowth.isNotEmpty) ...[
                      _buildSectionHeader('User Growth'),
                      const SizedBox(height: 12),
                      _buildUserGrowthChart(analyticsState),
                      const SizedBox(height: 32),
                    ],

                    // Trip Statistics Chart
                    if (analyticsState.tripStats.isNotEmpty) ...[
                      _buildSectionHeader('Trip Statistics'),
                      const SizedBox(height: 12),
                      _buildTripStatsChart(analyticsState),
                      const SizedBox(height: 32),
                    ],

                    // Match Statistics Pie Chart
                    if (analyticsState.matchStats.isNotEmpty) ...[
                      _buildSectionHeader('Match Success Rate'),
                      const SizedBox(height: 12),
                      _buildMatchStatsChart(analyticsState),
                      const SizedBox(height: 32),
                    ],

                    // Performance Metrics
                    if (analyticsState.performanceMetrics != null) ...[
                      _buildSectionHeader('System Performance'),
                      const SizedBox(height: 12),
                      _buildPerformanceMetrics(analyticsState),
                      const SizedBox(height: 24),
                    ],

                    // Error State
                    if (analyticsState.error != null)
                      _buildErrorBanner(analyticsState.error!),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSelector(AnalyticsState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PeriodChip(
            label: 'Daily',
            isSelected: state.selectedPeriod == 'daily',
            onTap: () {
              ref
                  .read(analyticsViewModelProvider.notifier)
                  .changePeriod('daily');
            },
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Weekly',
            isSelected: state.selectedPeriod == 'weekly',
            onTap: () {
              ref
                  .read(analyticsViewModelProvider.notifier)
                  .changePeriod('weekly');
            },
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Monthly',
            isSelected: state.selectedPeriod == 'monthly',
            onTap: () {
              ref
                  .read(analyticsViewModelProvider.notifier)
                  .changePeriod('monthly');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: context.textPrimary,
      ),
    );
  }

  Widget _buildOverviewCards(AnalyticsState state) {
    final overview = state.overview!;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MetricCard(
          title: 'Total Users',
          value: _formatNumber(overview.totalUsers),
          icon: Icons.people_rounded,
          color: Colors.blue,
        ),
        _MetricCard(
          title: 'Total Trips',
          value: _formatNumber(overview.totalTrips),
          icon: Icons.luggage_rounded,
          color: Colors.green,
        ),
        _MetricCard(
          title: 'Active Users',
          value: _formatNumber(overview.activeUsers),
          icon: Icons.person_rounded,
          color: Colors.orange,
        ),
        _MetricCard(
          title: 'Total Matches',
          value: _formatNumber(overview.totalMatches),
          icon: Icons.favorite_rounded,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildUserGrowthChart(AnalyticsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'New vs Active Users',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= state.userGrowth.length) {
                          return const Text('');
                        }
                        final date = state.userGrowth[value.toInt()].date;
                        return Text(
                          date.substring(date.length - 5),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // New Users Line
                  LineChartBarData(
                    spots: state.userGrowth
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value.newUsers.toDouble(),
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  // Active Users Line
                  LineChartBarData(
                    spots: state.userGrowth
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value.activeUsers.toDouble(),
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripStatsChart(AnalyticsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Trips Created vs Completed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: state.tripStats
                    .map((e) => e.tripsCreated.toDouble())
                    .reduce((a, b) => a > b ? a : b),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= state.tripStats.length) {
                          return const Text('');
                        }
                        final date = state.tripStats[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            date.substring(date.length - 5),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: state.tripStats.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.tripsCreated.toDouble(),
                        color: Colors.blue,
                        width: 12,
                      ),
                      BarChartRodData(
                        toY: e.value.tripsCompleted.toDouble(),
                        color: Colors.green,
                        width: 12,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStatsChart(AnalyticsState state) {
    final latestMatch = state.matchStats.isNotEmpty
        ? state.matchStats.last
        : null;

    if (latestMatch == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Match Success Rate (${latestMatch.successRate.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: latestMatch.matchesAccepted.toDouble(),
                          color: Colors.green,
                          title: '${latestMatch.matchesAccepted}\nAccepted',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: latestMatch.matchesRejected.toDouble(),
                          color: Colors.red,
                          title: '${latestMatch.matchesRejected}\nRejected',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(color: Colors.green, label: 'Accepted'),
                    const SizedBox(height: 8),
                    _LegendItem(color: Colors.red, label: 'Rejected'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(AnalyticsState state) {
    final metrics = state.performanceMetrics!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          _StatRow(
            label: 'API Latency',
            value: '${metrics.apiLatencyMs.toStringAsFixed(0)}ms',
            icon: Icons.speed_rounded,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Error Count',
            value: metrics.errorCount.toString(),
            icon: Icons.error_outline_rounded,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Uptime',
            value: '${metrics.uptime.toStringAsFixed(2)}%',
            icon: Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              ref.read(analyticsViewModelProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Colors.blue, Colors.blue.shade700])
              : null,
          color: !isSelected ? context.surfaceColor : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? context.cardShadow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.cardShadow,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: context.textSecondary, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: context.textSecondary),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: context.textPrimary)),
      ],
    );
  }
}

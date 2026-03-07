import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/admin/domain/entities/report_entity.dart';
import 'package:tripmates/features/admin/presentation/view_model/reports_management_state.dart';

class ReportsManagementPage extends ConsumerStatefulWidget {
  const ReportsManagementPage({super.key});

  @override
  ConsumerState<ReportsManagementPage> createState() =>
      _ReportsManagementPageState();
}

class _ReportsManagementPageState extends ConsumerState<ReportsManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(reportsManagementViewModelProvider.notifier)
          .loadReportsAndStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsManagementViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(reportsManagementViewModelProvider.notifier)
                  .loadReportsAndStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ref
                  .read(reportsManagementViewModelProvider.notifier)
                  .clearFilters();
            },
          ),
        ],
      ),
      body:
          state.status == ReportsManagementStatus.loading &&
              state.reports.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Statistics Cards
                  if (state.stats != null) ...[
                    _buildStatsCards(state, context),
                  ],

                  // Filter Controls
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildFilterControls(state, context),
                  ),

                  // Error Banner
                  if (state.error != null) ...[
                    _buildErrorBanner(state.error!, context),
                  ],

                  // Reports List
                  if (state.reports.isEmpty &&
                      state.status == ReportsManagementStatus.loaded)
                    _buildEmptyState(context)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildReportsList(state, context),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards(ReportsManagementState state, BuildContext context) {
    final stats = state.stats ?? {};
    final totalReports = stats['totalReports'] ?? 0;
    final pendingReports = stats['pendingReports'] ?? 0;
    final underReviewReports = stats['underReviewReports'] ?? 0;
    final resolvedReports = stats['resolvedReports'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStatCard(
            title: 'Total Reports',
            value: totalReports.toString(),
            color: Colors.blue,
            context: context,
          ),
          _buildStatCard(
            title: 'Pending',
            value: pendingReports.toString(),
            color: Colors.orange,
            context: context,
          ),
          _buildStatCard(
            title: 'Under Review',
            value: underReviewReports.toString(),
            color: Colors.purple,
            context: context,
          ),
          _buildStatCard(
            title: 'Resolved',
            value: resolvedReports.toString(),
            color: Colors.green,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls(
    ReportsManagementState state,
    BuildContext context,
  ) {
    final statusOptions = ['Pending', 'Under Review', 'Resolved', 'Dismissed'];
    final typeOptions = [
      'Inappropriate Behavior',
      'Harassment',
      'Fraud',
      'Safety Concern',
      'Offensive Content',
      'Spam',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filter
        Text('Filter by Status', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: statusOptions
                .map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected:
                          state.filter.statusFilter ==
                          status.toLowerCase().replaceAll(' ', '_'),
                      onSelected: (selected) {
                        ref
                            .read(reportsManagementViewModelProvider.notifier)
                            .changeStatusFilter(
                              selected
                                  ? status.toLowerCase().replaceAll(' ', '_')
                                  : null,
                            );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Type Filter
        Text('Filter by Type', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: typeOptions
                .map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected:
                          state.filter.typeFilter ==
                          type.toLowerCase().replaceAll(' ', '_'),
                      onSelected: (selected) {
                        ref
                            .read(reportsManagementViewModelProvider.notifier)
                            .changeTypeFilter(
                              selected
                                  ? type.toLowerCase().replaceAll(' ', '_')
                                  : null,
                            );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String error, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.report_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Reports Found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'There are no reports matching your filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList(ReportsManagementState state, BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final report = state.reports[index];
        return _buildReportCard(report, state, context);
      },
    );
  }

  Widget _buildReportCard(
    ReportEntity report,
    ReportsManagementState state,
    BuildContext context,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reported: ${report.reportedUserName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${report.type.toString().split('.').last.replaceAll('_', ' ')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(report.status),
              ],
            ),
            const SizedBox(height: 12),

            // Reason
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                report.reason,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // Metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'By: ${report.reportingUserName}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  _formatDate(report.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                if (report.status == ReportStatus.pending)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Review'),
                      onPressed: () {
                        _showReviewDialog(report, state);
                      },
                    ),
                  )
                else if (report.status == ReportStatus.under_review)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Resolve'),
                      onPressed: () {
                        _showResolveDialog(report, state);
                      },
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Details'),
                    onPressed: () {
                      _showDetailDialog(report, state);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    final colors = {
      ReportStatus.pending: Colors.orange,
      ReportStatus.under_review: Colors.blue,
      ReportStatus.resolved: Colors.green,
      ReportStatus.dismissed: Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors[status]?.withValues(alpha: 0.1),
        border: Border.all(color: colors[status]!.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colors[status],
        ),
      ),
    );
  }

  void _showReviewDialog(ReportEntity report, ReportsManagementState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report ID: ${report.id}'),
            const SizedBox(height: 8),
            const Text('Update Status:'),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              ref
                  .read(reportsManagementViewModelProvider.notifier)
                  .reviewReport(reportId: report.id, status: 'under_review');
              Navigator.pop(context);
            },
            child: const Text('Mark Under Review'),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(ReportEntity report, ReportsManagementState state) {
    String selectedAction = 'dismiss';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Resolve Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report ID: ${report.id}'),
              const SizedBox(height: 16),
              const Text('Choose Action:'),
              const SizedBox(height: 8),
              ...['warn', 'suspend', 'ban', 'dismiss'].map((action) {
                return RadioListTile<String>(
                  title: Text(action.toUpperCase()),
                  value: action,
                  // ignore: deprecated_member_use
                  groupValue: selectedAction,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    setState(() => selectedAction = value ?? 'dismiss');
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                ref
                    .read(reportsManagementViewModelProvider.notifier)
                    .resolveReport(reportId: report.id, action: selectedAction);
                Navigator.pop(context);
              },
              child: Text('Resolve with $selectedAction'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(ReportEntity report, ReportsManagementState state) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Report Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                _detailField('Report ID', report.id),
                _detailField('Reported User', report.reportedUserName),
                _detailField('Type', report.type.toString().split('.').last),
                _detailField(
                  'Status',
                  report.status.toString().split('.').last,
                ),
                _detailField('Reason', report.reason),
                if (report.notes != null)
                  _detailField('Admin Notes', report.notes!),
                _detailField('Created', _formatDate(report.createdAt)),
                if (report.resolvedAt != null)
                  _detailField('Resolved', _formatDate(report.resolvedAt!)),
                if (report.resolvedBy != null)
                  _detailField('Resolved By', report.resolvedBy!),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

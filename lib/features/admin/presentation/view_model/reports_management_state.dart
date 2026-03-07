import 'dart:developer' as developer;
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/admin/domain/entities/report_entity.dart';
import 'package:tripmates/features/admin/data/repositories/reports_repository.dart';
import 'package:tripmates/features/admin/domain/usecases/reports_usecases.dart';

/// Reports Management Status Enum
enum ReportsManagementStatus { initial, loading, loaded, error }

/// Reports Filter State
class ReportsFilter extends Equatable {
  final String? statusFilter;
  final String? typeFilter;
  final int page;
  final int limit;

  const ReportsFilter({
    this.statusFilter,
    this.typeFilter,
    this.page = 1,
    this.limit = 20,
  });

  ReportsFilter copyWith({
    String? statusFilter,
    String? typeFilter,
    int? page,
    int? limit,
  }) {
    return ReportsFilter(
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [statusFilter, typeFilter, page, limit];
}

/// Reports Management State
class ReportsManagementState extends Equatable {
  final ReportsManagementStatus status;
  final List<ReportEntity> reports;
  final Map<String, dynamic>? stats;
  final ReportEntity? selectedReport;
  final String? error;
  final ReportsFilter filter;
  final bool isLoadingAction;
  final String? actionError;

  const ReportsManagementState({
    this.status = ReportsManagementStatus.initial,
    this.reports = const [],
    this.stats,
    this.selectedReport,
    this.error,
    this.filter = const ReportsFilter(),
    this.isLoadingAction = false,
    this.actionError,
  });

  @override
  List<Object?> get props => [
    status,
    reports,
    stats,
    selectedReport,
    error,
    filter,
    isLoadingAction,
    actionError,
  ];

  ReportsManagementState copyWith({
    ReportsManagementStatus? status,
    List<ReportEntity>? reports,
    Map<String, dynamic>? stats,
    ReportEntity? selectedReport,
    String? error,
    ReportsFilter? filter,
    bool? isLoadingAction,
    String? actionError,
  }) {
    return ReportsManagementState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      stats: stats ?? this.stats,
      selectedReport: selectedReport ?? this.selectedReport,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
      actionError: actionError ?? this.actionError,
    );
  }
}

/// Reports Management ViewModel
class ReportsManagementViewModel extends Notifier<ReportsManagementState> {
  late final GetAllReportsUsecase getAllReportsUsecase;
  late final GetReportStatsUsecase getReportStatsUsecase;
  late final ReviewReportUsecase reviewReportUsecase;
  late final ResolveReportUsecase resolveReportUsecase;

  @override
  ReportsManagementState build() {
    getAllReportsUsecase = ref.read(getAllReportsUsecaseProvider);
    getReportStatsUsecase = ref.read(getReportStatsUsecaseProvider);
    reviewReportUsecase = ref.read(reviewReportUsecaseProvider);
    resolveReportUsecase = ref.read(resolveReportUsecaseProvider);

    return const ReportsManagementState();
  }

  Future<void> loadReportsAndStats() async {
    await loadReports();
    await loadStats();
  }

  Future<void> loadReports() async {
    state = state.copyWith(status: ReportsManagementStatus.loading);

    final result = await getAllReportsUsecase(
      GetAllReportsParams(
        page: state.filter.page,
        limit: state.filter.limit,
        status: state.filter.statusFilter,
        type: state.filter.typeFilter,
      ),
    );

    result.fold(
      (failure) {
        developer.log('loadReports error: ${failure.toString()}');
        state = state.copyWith(
          status: ReportsManagementStatus.error,
          error: failure is ApiFailure
              ? failure.message
              : 'Failed to load reports',
        );
      },
      (reports) {
        developer.log('loadReports: Loaded ${reports.length} reports');
        state = state.copyWith(
          status: ReportsManagementStatus.loaded,
          reports: reports,
          error: null,
        );
      },
    );
  }

  Future<void> loadStats() async {
    final result = await getReportStatsUsecase();

    result.fold(
      (failure) {
        developer.log('loadStats error: ${failure.toString()}');
      },
      (stats) {
        developer.log('loadStats: Loaded statistics');
        state = state.copyWith(stats: stats);
      },
    );
  }

  Future<void> selectReport(String reportId) async {
    final report = state.reports.firstWhere(
      (r) => r.id == reportId,
      orElse: () => state.selectedReport ?? state.reports.first,
    );
    state = state.copyWith(selectedReport: report);
  }

  Future<void> clearSelectedReport() async {
    state = state.copyWith(selectedReport: null);
  }

  Future<void> reviewReport({
    required String reportId,
    required String status,
    String? notes,
  }) async {
    state = state.copyWith(isLoadingAction: true, actionError: null);

    final result = await reviewReportUsecase(
      ReviewReportParams(reportId: reportId, status: status, notes: notes),
    );

    result.fold(
      (failure) {
        developer.log('reviewReport error: ${failure.toString()}');
        state = state.copyWith(
          isLoadingAction: false,
          actionError: failure is ApiFailure
              ? failure.message
              : 'Failed to review report',
        );
      },
      (updatedReport) {
        developer.log('reviewReport: Report $reportId updated');
        // Update the report in the list
        final updatedReports = state.reports.map((r) {
          if (r.id == reportId) return updatedReport;
          return r;
        }).toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: updatedReport,
          isLoadingAction: false,
          actionError: null,
        );
      },
    );
  }

  Future<void> resolveReport({
    required String reportId,
    required String action, // 'warn', 'suspend', 'ban', 'dismiss'
    String? notes,
  }) async {
    state = state.copyWith(isLoadingAction: true, actionError: null);

    final result = await resolveReportUsecase(
      ResolveReportParams(reportId: reportId, action: action, notes: notes),
    );

    result.fold(
      (failure) {
        developer.log('resolveReport error: ${failure.toString()}');
        state = state.copyWith(
          isLoadingAction: false,
          actionError: failure is ApiFailure
              ? failure.message
              : 'Failed to resolve report',
        );
      },
      (updatedReport) {
        developer.log(
          'resolveReport: Report $reportId resolved with action $action',
        );
        // Update the report in the list
        final updatedReports = state.reports.map((r) {
          if (r.id == reportId) return updatedReport;
          return r;
        }).toList();

        state = state.copyWith(
          reports: updatedReports,
          selectedReport: updatedReport,
          isLoadingAction: false,
          actionError: null,
        );
      },
    );
  }

  void changeStatusFilter(String? status) {
    final newFilter = state.filter.copyWith(statusFilter: status, page: 1);
    state = state.copyWith(filter: newFilter);
    loadReports();
  }

  void changeTypeFilter(String? type) {
    final newFilter = state.filter.copyWith(typeFilter: type, page: 1);
    state = state.copyWith(filter: newFilter);
    loadReports();
  }

  void clearFilters() {
    state = state.copyWith(filter: const ReportsFilter(), selectedReport: null);
    loadReportsAndStats();
  }

  void clearActionError() {
    state = state.copyWith(actionError: null);
  }
}

// Riverpod Provider
final reportsManagementViewModelProvider =
    NotifierProvider<ReportsManagementViewModel, ReportsManagementState>(() {
      return ReportsManagementViewModel();
    });

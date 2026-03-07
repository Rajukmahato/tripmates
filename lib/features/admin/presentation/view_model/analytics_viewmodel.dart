import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/admin/data/repositories/analytics_repository.dart';
import 'package:tripmates/features/admin/domain/usecases/analytics_usecases.dart';
import 'package:tripmates/features/admin/presentation/view_model/analytics_state.dart';

/// Riverpod provider for analytics viewmodel
final analyticsViewModelProvider =
    NotifierProvider<AnalyticsViewModel, AnalyticsState>(() {
      return AnalyticsViewModel();
    });

/// AnalyticsViewModel - Manages analytics data and state
class AnalyticsViewModel extends Notifier<AnalyticsState> {
  late final GetPlatformOverviewUsecase _getPlatformOverviewUsecase;
  late final GetUserAnalyticsUsecase _getUserAnalyticsUsecase;
  late final GetTripAnalyticsUsecase _getTripAnalyticsUsecase;
  late final GetMatchAnalyticsUsecase _getMatchAnalyticsUsecase;
  late final GetPerformanceMetricsUsecase _getPerformanceMetricsUsecase;

  @override
  AnalyticsState build() {
    // Initialize use cases
    _getPlatformOverviewUsecase = ref.read(getPlatformOverviewUsecaseProvider);
    _getUserAnalyticsUsecase = ref.read(getUserAnalyticsUsecaseProvider);
    _getTripAnalyticsUsecase = ref.read(getTripAnalyticsUsecaseProvider);
    _getMatchAnalyticsUsecase = ref.read(getMatchAnalyticsUsecaseProvider);
    _getPerformanceMetricsUsecase = ref.read(
      getPerformanceMetricsUsecaseProvider,
    );

    return const AnalyticsState();
  }

  /// Load all analytics data
  Future<void> loadAllAnalytics() async {
    await loadPlatformOverview();
    await loadUserGrowth();
    await loadTripStats();
    await loadMatchStats();
    await loadPerformanceMetrics();
  }

  /// Load platform overview statistics
  Future<void> loadPlatformOverview() async {
    state = state.copyWith(isLoadingOverview: true);
    log('Loading platform overview analytics');

    final result = await _getPlatformOverviewUsecase();

    result.fold(
      (failure) {
        log('Error loading platform overview: ${failure.message}');
        state = state.copyWith(
          status: AnalyticsStateStatus.error,
          error: failure.message,
          isLoadingOverview: false,
        );
      },
      (overview) {
        log('Platform overview loaded successfully');
        state = state.copyWith(
          overview: overview,
          status: AnalyticsStateStatus.loaded,
          isLoadingOverview: false,
        );
      },
    );
  }

  /// Load user growth analytics
  Future<void> loadUserGrowth() async {
    state = state.copyWith(isLoadingUserGrowth: true);
    log('Loading user growth analytics for period: ${state.selectedPeriod}');

    final result = await _getUserAnalyticsUsecase(
      GetUserAnalyticsParams(period: state.selectedPeriod),
    );

    result.fold(
      (failure) {
        log('Error loading user growth: ${failure.message}');
        state = state.copyWith(
          status: AnalyticsStateStatus.error,
          error: failure.message,
          isLoadingUserGrowth: false,
        );
      },
      (userGrowth) {
        log('User growth loaded successfully: ${userGrowth.length} records');
        state = state.copyWith(
          userGrowth: userGrowth,
          status: AnalyticsStateStatus.loaded,
          isLoadingUserGrowth: false,
        );
      },
    );
  }

  /// Load trip statistics
  Future<void> loadTripStats() async {
    state = state.copyWith(isLoadingTripStats: true);
    log('Loading trip stats for period: ${state.selectedPeriod}');

    final result = await _getTripAnalyticsUsecase(
      GetTripAnalyticsParams(period: state.selectedPeriod),
    );

    result.fold(
      (failure) {
        log('Error loading trip stats: ${failure.message}');
        state = state.copyWith(
          status: AnalyticsStateStatus.error,
          error: failure.message,
          isLoadingTripStats: false,
        );
      },
      (tripStats) {
        log('Trip stats loaded successfully: ${tripStats.length} records');
        state = state.copyWith(
          tripStats: tripStats,
          status: AnalyticsStateStatus.loaded,
          isLoadingTripStats: false,
        );
      },
    );
  }

  /// Load match statistics
  Future<void> loadMatchStats() async {
    state = state.copyWith(isLoadingMatchStats: true);
    log('Loading match stats for period: ${state.selectedPeriod}');

    final result = await _getMatchAnalyticsUsecase(
      GetMatchAnalyticsParams(period: state.selectedPeriod),
    );

    result.fold(
      (failure) {
        log('Error loading match stats: ${failure.message}');
        state = state.copyWith(
          status: AnalyticsStateStatus.error,
          error: failure.message,
          isLoadingMatchStats: false,
        );
      },
      (matchStats) {
        log('Match stats loaded successfully: ${matchStats.length} records');
        state = state.copyWith(
          matchStats: matchStats,
          status: AnalyticsStateStatus.loaded,
          isLoadingMatchStats: false,
        );
      },
    );
  }

  /// Load performance metrics
  Future<void> loadPerformanceMetrics() async {
    state = state.copyWith(isLoadingPerformance: true);
    log('Loading performance metrics');

    final result = await _getPerformanceMetricsUsecase();

    result.fold(
      (failure) {
        log('Error loading performance metrics: ${failure.message}');
        state = state.copyWith(
          status: AnalyticsStateStatus.error,
          error: failure.message,
          isLoadingPerformance: false,
        );
      },
      (metrics) {
        log('Performance metrics loaded successfully');
        state = state.copyWith(
          performanceMetrics: metrics,
          status: AnalyticsStateStatus.loaded,
          isLoadingPerformance: false,
        );
      },
    );
  }

  /// Change the selected period and reload time-series data
  Future<void> changePeriod(String newPeriod) async {
    if (newPeriod == state.selectedPeriod) return;

    log('Changing period from ${state.selectedPeriod} to $newPeriod');
    state = state.copyWith(selectedPeriod: newPeriod);

    // Reload time-series data with new period
    await loadUserGrowth();
    await loadTripStats();
    await loadMatchStats();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh all data
  Future<void> refresh() async {
    log('Refreshing all analytics data');
    await loadAllAnalytics();
  }
}

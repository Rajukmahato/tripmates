import 'package:equatable/equatable.dart';
import 'package:tripmates/features/admin/data/models/analytics_model.dart';

/// Analytics state status enum
enum AnalyticsStateStatus { initial, loading, loaded, error }

/// Analytics state
class AnalyticsState extends Equatable {
  final AnalyticsStateStatus status;
  final String? error;

  // Platform overview
  final PlatformOverviewModel? overview;

  // Time-series data
  final List<UserGrowthModel> userGrowth;
  final List<TripStatsModel> tripStats;
  final List<MatchStatsModel> matchStats;

  // Performance metrics
  final PerformanceMetricsModel? performanceMetrics;

  // Currently selected period
  final String selectedPeriod; // daily, weekly, monthly

  // Loading states for individual sections
  final bool isLoadingOverview;
  final bool isLoadingUserGrowth;
  final bool isLoadingTripStats;
  final bool isLoadingMatchStats;
  final bool isLoadingPerformance;

  const AnalyticsState({
    this.status = AnalyticsStateStatus.initial,
    this.error,
    this.overview,
    this.userGrowth = const [],
    this.tripStats = const [],
    this.matchStats = const [],
    this.performanceMetrics,
    this.selectedPeriod = 'weekly',
    this.isLoadingOverview = false,
    this.isLoadingUserGrowth = false,
    this.isLoadingTripStats = false,
    this.isLoadingMatchStats = false,
    this.isLoadingPerformance = false,
  });

  AnalyticsState copyWith({
    AnalyticsStateStatus? status,
    String? error,
    PlatformOverviewModel? overview,
    List<UserGrowthModel>? userGrowth,
    List<TripStatsModel>? tripStats,
    List<MatchStatsModel>? matchStats,
    PerformanceMetricsModel? performanceMetrics,
    String? selectedPeriod,
    bool? isLoadingOverview,
    bool? isLoadingUserGrowth,
    bool? isLoadingTripStats,
    bool? isLoadingMatchStats,
    bool? isLoadingPerformance,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      error: error ?? this.error,
      overview: overview ?? this.overview,
      userGrowth: userGrowth ?? this.userGrowth,
      tripStats: tripStats ?? this.tripStats,
      matchStats: matchStats ?? this.matchStats,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoadingOverview: isLoadingOverview ?? this.isLoadingOverview,
      isLoadingUserGrowth: isLoadingUserGrowth ?? this.isLoadingUserGrowth,
      isLoadingTripStats: isLoadingTripStats ?? this.isLoadingTripStats,
      isLoadingMatchStats: isLoadingMatchStats ?? this.isLoadingMatchStats,
      isLoadingPerformance: isLoadingPerformance ?? this.isLoadingPerformance,
    );
  }

  /// Helper to check if any data is being loaded
  bool get isAnyLoading =>
      isLoadingOverview ||
      isLoadingUserGrowth ||
      isLoadingTripStats ||
      isLoadingMatchStats ||
      isLoadingPerformance;

  @override
  List<Object?> get props => [
    status,
    error,
    overview,
    userGrowth,
    tripStats,
    matchStats,
    performanceMetrics,
    selectedPeriod,
    isLoadingOverview,
    isLoadingUserGrowth,
    isLoadingTripStats,
    isLoadingMatchStats,
    isLoadingPerformance,
  ];
}

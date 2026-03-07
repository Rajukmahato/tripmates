import 'package:equatable/equatable.dart';
import 'package:tripmates/features/admin/domain/entities/admin_report_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_trip_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_user_entity.dart';

/// State for admin features
class AdminState extends Equatable {
  final AdminStatsEntity? stats;
  final List<AdminUserEntity> users;
  final List<AdminTripEntity> trips;
  final List<AdminReportEntity> reports;
  final bool isLoading;
  final bool isStatsLoading;
  final bool isUsersLoading;
  final bool isTripsLoading;
  final bool isReportsLoading;
  final String? error;

  const AdminState({
    this.stats,
    this.users = const [],
    this.trips = const [],
    this.reports = const [],
    this.isLoading = false,
    this.isStatsLoading = false,
    this.isUsersLoading = false,
    this.isTripsLoading = false,
    this.isReportsLoading = false,
    this.error,
  });

  AdminState copyWith({
    AdminStatsEntity? stats,
    List<AdminUserEntity>? users,
    List<AdminTripEntity>? trips,
    List<AdminReportEntity>? reports,
    bool? isLoading,
    bool? isStatsLoading,
    bool? isUsersLoading,
    bool? isTripsLoading,
    bool? isReportsLoading,
    String? error,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      users: users ?? this.users,
      trips: trips ?? this.trips,
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      isUsersLoading: isUsersLoading ?? this.isUsersLoading,
      isTripsLoading: isTripsLoading ?? this.isTripsLoading,
      isReportsLoading: isReportsLoading ?? this.isReportsLoading,
      error: error,
    );
  }

  /// Get pending reports count
  int get pendingReportsCount =>
      reports.where((r) => r.status == 'pending').length;

  /// Get active users count
  int get activeUsersCount => users.where((u) => u.isActive).length;

  /// Get active trips count
  int get activeTripsCount => trips.where((t) => t.isActive).length;

  @override
  List<Object?> get props => [
    stats,
    users,
    trips,
    reports,
    isLoading,
    isStatsLoading,
    isUsersLoading,
    isTripsLoading,
    isReportsLoading,
    error,
  ];
}

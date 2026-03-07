import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/admin/domain/usecases/get_all_admin_reports_usecase.dart';
import 'package:tripmates/features/admin/domain/usecases/get_all_admin_trips_usecase.dart';
import 'package:tripmates/features/admin/domain/usecases/get_all_users_usecase.dart';
import 'package:tripmates/features/admin/domain/usecases/get_overview_stats_usecase.dart';
import 'package:tripmates/features/admin/domain/usecases/review_report_usecase.dart';
import 'package:tripmates/features/admin/presentation/state/admin_state.dart';

/// ViewModel for admin dashboard
class AdminViewmodel extends Notifier<AdminState> {
  late final GetOverviewStatsUseCase _getOverviewStatsUseCase;
  late final GetAllUsersUseCase _getAllUsersUseCase;
  late final GetAllAdminTripsUseCase _getAllAdminTripsUseCase;
  late final GetAllAdminReportsUseCase _getAllAdminReportsUseCase;
  late final ReviewReportUseCase _reviewReportUseCase;

  @override
  AdminState build() {
    _getOverviewStatsUseCase = ref.watch(getOverviewStatsUseCaseProvider);
    _getAllUsersUseCase = ref.watch(getAllUsersUseCaseProvider);
    _getAllAdminTripsUseCase = ref.watch(getAllAdminTripsUseCaseProvider);
    _getAllAdminReportsUseCase = ref.watch(getAllAdminReportsUseCaseProvider);
    _reviewReportUseCase = ref.watch(reviewReportUseCaseProvider);
    return const AdminState();
  }

  /// Load overview statistics
  Future<void> loadStats() async {
    state = state.copyWith(isStatsLoading: true, error: null);

    final result = await _getOverviewStatsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(isStatsLoading: false, error: failure.message);
      },
      (stats) {
        state = state.copyWith(
          stats: stats,
          isStatsLoading: false,
          error: null,
        );
      },
    );
  }

  /// Load all users
  Future<void> loadUsers() async {
    state = state.copyWith(isUsersLoading: true, error: null);

    final result = await _getAllUsersUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(isUsersLoading: false, error: failure.message);
      },
      (users) {
        state = state.copyWith(
          users: users,
          isUsersLoading: false,
          error: null,
        );
      },
    );
  }

  /// Load all trips
  Future<void> loadTrips() async {
    state = state.copyWith(isTripsLoading: true, error: null);

    final result = await _getAllAdminTripsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(isTripsLoading: false, error: failure.message);
      },
      (trips) {
        state = state.copyWith(
          trips: trips,
          isTripsLoading: false,
          error: null,
        );
      },
    );
  }

  /// Load all reports
  Future<void> loadReports() async {
    state = state.copyWith(isReportsLoading: true, error: null);

    final result = await _getAllAdminReportsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(isReportsLoading: false, error: failure.message);
      },
      (reports) {
        state = state.copyWith(
          reports: reports,
          isReportsLoading: false,
          error: null,
        );
      },
    );
  }

  /// Review a report
  Future<bool> reviewReport(
    String reportId,
    String status,
    String? notes,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _reviewReportUseCase(
      ReviewReportParams(reportId: reportId, status: status, notes: notes),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (success) {
        state = state.copyWith(isLoading: false, error: null);
        // Reload reports after successful review
        loadReports();
        return true;
      },
    );
  }

  /// Load all data (for dashboard initialization)
  Future<void> loadAll() async {
    await Future.wait([loadStats(), loadUsers(), loadTrips(), loadReports()]);
  }

  /// Toggle user status (ban/unban)
  Future<void> toggleUserStatus(
    String userId,
    bool newStatus,
    String? reason,
  ) async {
    try {
      // Optimistic update - update local state immediately
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user; // In a real implementation, update the user object with new status
        }
        return user;
      }).toList();

      state = state.copyWith(users: updatedUsers);

      // In a real implementation, call API here
      // For now, simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload users to get updated data
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update user status');
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId, String reason) async {
    try {
      // Optimistic update
      final updatedUsers = state.users
          .where((user) => user.id != userId)
          .toList();
      state = state.copyWith(users: updatedUsers);

      // In a real implementation, call API here
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload users
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete user');
    }
  }

  /// Toggle trip status (activate/deactivate)
  Future<void> toggleTripStatus(String tripId, bool newStatus) async {
    try {
      // Optimistic update
      final updatedTrips = state.trips.map((trip) {
        if (trip.id == tripId) {
          return trip; // In real implementation, update trip status
        }
        return trip;
      }).toList();

      state = state.copyWith(trips: updatedTrips);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload trips
      await loadTrips();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update trip status');
    }
  }

  /// Feature/unfeature a trip
  Future<void> featureTrip(String tripId, bool featured) async {
    try {
      // Optimistic update
      final updatedTrips = state.trips.map((trip) {
        if (trip.id == tripId) {
          return trip; // In real implementation, update featured flag
        }
        return trip;
      }).toList();

      state = state.copyWith(trips: updatedTrips);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload trips
      await loadTrips();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update trip feature status');
    }
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId, String reason) async {
    try {
      // Optimistic update
      final updatedTrips = state.trips
          .where((trip) => trip.id != tripId)
          .toList();
      state = state.copyWith(trips: updatedTrips);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload trips
      await loadTrips();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete trip');
    }
  }

  /// Resolve report (change status to resolved/dismissed)
  Future<void> resolveReport(
    String reportId,
    String resolution,
    String? notes,
  ) async {
    try {
      // Optimistic update
      final updatedReports = state.reports.map((report) {
        if (report.id == reportId) {
          return report; // In real implementation, update report status
        }
        return report;
      }).toList();

      state = state.copyWith(reports: updatedReports);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload reports and stats
      await Future.wait([loadReports(), loadStats()]);
    } catch (e) {
      state = state.copyWith(error: 'Failed to resolve report');
    }
  }

  /// Reset state
  void resetState() {
    state = const AdminState();
  }
}

/// Provider
final adminViewmodelProvider = NotifierProvider<AdminViewmodel, AdminState>(
  () => AdminViewmodel(),
);

import 'package:equatable/equatable.dart';

/// Entity for admin dashboard statistics
class AdminStatsEntity extends Equatable {
  final int totalUsers;
  final int activeUsers;
  final int totalTrips;
  final int activeTrips;
  final int totalReports;
  final int pendingReports;
  final int totalReviews;
  final int totalMatches;
  final Map<String, dynamic>? userGrowth; // Daily/weekly/monthly growth
  final Map<String, dynamic>? tripGrowth;
  final Map<String, dynamic>? revenueData;

  const AdminStatsEntity({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalTrips,
    required this.activeTrips,
    required this.totalReports,
    required this.pendingReports,
    required this.totalReviews,
    required this.totalMatches,
    this.userGrowth,
    this.tripGrowth,
    this.revenueData,
  });

  AdminStatsEntity copyWith({
    int? totalUsers,
    int? activeUsers,
    int? totalTrips,
    int? activeTrips,
    int? totalReports,
    int? pendingReports,
    int? totalReviews,
    int? totalMatches,
    Map<String, dynamic>? userGrowth,
    Map<String, dynamic>? tripGrowth,
    Map<String, dynamic>? revenueData,
  }) {
    return AdminStatsEntity(
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      totalTrips: totalTrips ?? this.totalTrips,
      activeTrips: activeTrips ?? this.activeTrips,
      totalReports: totalReports ?? this.totalReports,
      pendingReports: pendingReports ?? this.pendingReports,
      totalReviews: totalReviews ?? this.totalReviews,
      totalMatches: totalMatches ?? this.totalMatches,
      userGrowth: userGrowth ?? this.userGrowth,
      tripGrowth: tripGrowth ?? this.tripGrowth,
      revenueData: revenueData ?? this.revenueData,
    );
  }

  @override
  List<Object?> get props => [
    totalUsers,
    activeUsers,
    totalTrips,
    activeTrips,
    totalReports,
    pendingReports,
    totalReviews,
    totalMatches,
    userGrowth,
    tripGrowth,
    revenueData,
  ];
}

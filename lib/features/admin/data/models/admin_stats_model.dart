import 'package:tripmates/features/admin/domain/entities/admin_stats_entity.dart';

int? _parseIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

/// Model for admin statistics
class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalUsers,
    required super.activeUsers,
    required super.totalTrips,
    required super.activeTrips,
    required super.totalReports,
    required super.pendingReports,
    required super.totalReviews,
    required super.totalMatches,
    super.userGrowth,
    super.tripGrowth,
    super.revenueData,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: _parseIntValue(json['totalUsers']) ?? 0,
      activeUsers: _parseIntValue(json['activeUsers']) ?? 0,
      totalTrips: _parseIntValue(json['totalTrips']) ?? 0,
      activeTrips: _parseIntValue(json['activeTrips']) ?? 0,
      totalReports: _parseIntValue(json['totalReports']) ?? 0,
      pendingReports: _parseIntValue(json['pendingReports']) ?? 0,
      totalReviews: _parseIntValue(json['totalReviews']) ?? 0,
      totalMatches: _parseIntValue(json['totalMatches']) ?? 0,
      userGrowth: json['userGrowth'] as Map<String, dynamic>?,
      tripGrowth: json['tripGrowth'] as Map<String, dynamic>?,
      revenueData: json['revenueData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalTrips': totalTrips,
      'activeTrips': activeTrips,
      'totalReports': totalReports,
      'pendingReports': pendingReports,
      'totalReviews': totalReviews,
      'totalMatches': totalMatches,
      'userGrowth': userGrowth,
      'tripGrowth': tripGrowth,
      'revenueData': revenueData,
    };
  }

  factory AdminStatsModel.fromEntity(AdminStatsEntity entity) {
    return AdminStatsModel(
      totalUsers: entity.totalUsers,
      activeUsers: entity.activeUsers,
      totalTrips: entity.totalTrips,
      activeTrips: entity.activeTrips,
      totalReports: entity.totalReports,
      pendingReports: entity.pendingReports,
      totalReviews: entity.totalReviews,
      totalMatches: entity.totalMatches,
      userGrowth: entity.userGrowth,
      tripGrowth: entity.tripGrowth,
      revenueData: entity.revenueData,
    );
  }
}

import 'package:equatable/equatable.dart';

/// Platform Overview Model - High-level platform statistics
class PlatformOverviewModel extends Equatable {
  final int totalUsers;
  final int totalTrips;
  final int totalMatches;
  final int activeUsers; // Users active in last 30 days
  final double averageRating;
  final int reportedIssues;

  const PlatformOverviewModel({
    required this.totalUsers,
    required this.totalTrips,
    required this.totalMatches,
    required this.activeUsers,
    required this.averageRating,
    required this.reportedIssues,
  });

  factory PlatformOverviewModel.fromJson(Map<String, dynamic> json) {
    return PlatformOverviewModel(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reportedIssues: (json['reportedIssues'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalTrips': totalTrips,
      'totalMatches': totalMatches,
      'activeUsers': activeUsers,
      'averageRating': averageRating,
      'reportedIssues': reportedIssues,
    };
  }

  PlatformOverviewModel copyWith({
    int? totalUsers,
    int? totalTrips,
    int? totalMatches,
    int? activeUsers,
    double? averageRating,
    int? reportedIssues,
  }) {
    return PlatformOverviewModel(
      totalUsers: totalUsers ?? this.totalUsers,
      totalTrips: totalTrips ?? this.totalTrips,
      totalMatches: totalMatches ?? this.totalMatches,
      activeUsers: activeUsers ?? this.activeUsers,
      averageRating: averageRating ?? this.averageRating,
      reportedIssues: reportedIssues ?? this.reportedIssues,
    );
  }

  @override
  List<Object?> get props => [
    totalUsers,
    totalTrips,
    totalMatches,
    activeUsers,
    averageRating,
    reportedIssues,
  ];
}

/// User Growth Model - Time-series user growth data
class UserGrowthModel extends Equatable {
  final String date; // Format: YYYY-MM-DD
  final int newUsers;
  final int activeUsers;
  final int churnedUsers; // Users who haven't been active

  const UserGrowthModel({
    required this.date,
    required this.newUsers,
    required this.activeUsers,
    required this.churnedUsers,
  });

  factory UserGrowthModel.fromJson(Map<String, dynamic> json) {
    return UserGrowthModel(
      date: json['date'] as String? ?? '',
      newUsers: (json['newUsers'] as num?)?.toInt() ?? 0,
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
      churnedUsers: (json['churnedUsers'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'newUsers': newUsers,
      'activeUsers': activeUsers,
      'churnedUsers': churnedUsers,
    };
  }

  UserGrowthModel copyWith({
    String? date,
    int? newUsers,
    int? activeUsers,
    int? churnedUsers,
  }) {
    return UserGrowthModel(
      date: date ?? this.date,
      newUsers: newUsers ?? this.newUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      churnedUsers: churnedUsers ?? this.churnedUsers,
    );
  }

  @override
  List<Object?> get props => [date, newUsers, activeUsers, churnedUsers];
}

/// Trip Statistics Model - Trip-related metrics
class TripStatsModel extends Equatable {
  final String date; // Format: YYYY-MM-DD
  final int tripsCreated;
  final int tripsCompleted;
  final int tripsCancelled;
  final double averageParticipants;
  final int totalDistance; // in km
  final int totalDuration; // in hours

  const TripStatsModel({
    required this.date,
    required this.tripsCreated,
    required this.tripsCompleted,
    required this.tripsCancelled,
    required this.averageParticipants,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory TripStatsModel.fromJson(Map<String, dynamic> json) {
    return TripStatsModel(
      date: json['date'] as String? ?? '',
      tripsCreated: (json['tripsCreated'] as num?)?.toInt() ?? 0,
      tripsCompleted: (json['tripsCompleted'] as num?)?.toInt() ?? 0,
      tripsCancelled: (json['tripsCancelled'] as num?)?.toInt() ?? 0,
      averageParticipants:
          (json['averageParticipants'] as num?)?.toDouble() ?? 0.0,
      totalDistance: (json['totalDistance'] as num?)?.toInt() ?? 0,
      totalDuration: (json['totalDuration'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'tripsCreated': tripsCreated,
      'tripsCompleted': tripsCompleted,
      'tripsCancelled': tripsCancelled,
      'averageParticipants': averageParticipants,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
    };
  }

  TripStatsModel copyWith({
    String? date,
    int? tripsCreated,
    int? tripsCompleted,
    int? tripsCancelled,
    double? averageParticipants,
    int? totalDistance,
    int? totalDuration,
  }) {
    return TripStatsModel(
      date: date ?? this.date,
      tripsCreated: tripsCreated ?? this.tripsCreated,
      tripsCompleted: tripsCompleted ?? this.tripsCompleted,
      tripsCancelled: tripsCancelled ?? this.tripsCancelled,
      averageParticipants: averageParticipants ?? this.averageParticipants,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  @override
  List<Object?> get props => [
    date,
    tripsCreated,
    tripsCompleted,
    tripsCancelled,
    averageParticipants,
    totalDistance,
    totalDuration,
  ];
}

/// Match Statistics Model - Trip matching and connection metrics
class MatchStatsModel extends Equatable {
  final String date; // Format: YYYY-MM-DD
  final int matchesCreated;
  final int matchesAccepted;
  final int matchesRejected;
  final double successRate; // Percentage: 0-100
  final double conversionRate; // Matched to trip completion rate
  final int averageTimeToMatch; // in minutes

  const MatchStatsModel({
    required this.date,
    required this.matchesCreated,
    required this.matchesAccepted,
    required this.matchesRejected,
    required this.successRate,
    required this.conversionRate,
    required this.averageTimeToMatch,
  });

  factory MatchStatsModel.fromJson(Map<String, dynamic> json) {
    return MatchStatsModel(
      date: json['date'] as String? ?? '',
      matchesCreated: (json['matchesCreated'] as num?)?.toInt() ?? 0,
      matchesAccepted: (json['matchesAccepted'] as num?)?.toInt() ?? 0,
      matchesRejected: (json['matchesRejected'] as num?)?.toInt() ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
      averageTimeToMatch: (json['averageTimeToMatch'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'matchesCreated': matchesCreated,
      'matchesAccepted': matchesAccepted,
      'matchesRejected': matchesRejected,
      'successRate': successRate,
      'conversionRate': conversionRate,
      'averageTimeToMatch': averageTimeToMatch,
    };
  }

  MatchStatsModel copyWith({
    String? date,
    int? matchesCreated,
    int? matchesAccepted,
    int? matchesRejected,
    double? successRate,
    double? conversionRate,
    int? averageTimeToMatch,
  }) {
    return MatchStatsModel(
      date: date ?? this.date,
      matchesCreated: matchesCreated ?? this.matchesCreated,
      matchesAccepted: matchesAccepted ?? this.matchesAccepted,
      matchesRejected: matchesRejected ?? this.matchesRejected,
      successRate: successRate ?? this.successRate,
      conversionRate: conversionRate ?? this.conversionRate,
      averageTimeToMatch: averageTimeToMatch ?? this.averageTimeToMatch,
    );
  }

  @override
  List<Object?> get props => [
    date,
    matchesCreated,
    matchesAccepted,
    matchesRejected,
    successRate,
    conversionRate,
    averageTimeToMatch,
  ];
}

/// Performance Metrics Model - System performance and health indicators
class PerformanceMetricsModel extends Equatable {
  final String timestamp; // ISO 8601 format
  final double apiLatencyMs; // Average API response time in milliseconds
  final double appCrashRate; // Percentage: 0-100
  final int errorCount;
  final double cpuUsage; // Percentage: 0-100
  final double memoryUsageMb;
  final int databaseQueryTime; // in milliseconds
  final double uptime; // Percentage: 0-100

  const PerformanceMetricsModel({
    required this.timestamp,
    required this.apiLatencyMs,
    required this.appCrashRate,
    required this.errorCount,
    required this.cpuUsage,
    required this.memoryUsageMb,
    required this.databaseQueryTime,
    required this.uptime,
  });

  factory PerformanceMetricsModel.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricsModel(
      timestamp: json['timestamp'] as String? ?? '',
      apiLatencyMs: (json['apiLatencyMs'] as num?)?.toDouble() ?? 0.0,
      appCrashRate: (json['appCrashRate'] as num?)?.toDouble() ?? 0.0,
      errorCount: (json['errorCount'] as num?)?.toInt() ?? 0,
      cpuUsage: (json['cpuUsage'] as num?)?.toDouble() ?? 0.0,
      memoryUsageMb: (json['memoryUsageMb'] as num?)?.toDouble() ?? 0.0,
      databaseQueryTime: (json['databaseQueryTime'] as num?)?.toInt() ?? 0,
      uptime: (json['uptime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'apiLatencyMs': apiLatencyMs,
      'appCrashRate': appCrashRate,
      'errorCount': errorCount,
      'cpuUsage': cpuUsage,
      'memoryUsageMb': memoryUsageMb,
      'databaseQueryTime': databaseQueryTime,
      'uptime': uptime,
    };
  }

  PerformanceMetricsModel copyWith({
    String? timestamp,
    double? apiLatencyMs,
    double? appCrashRate,
    int? errorCount,
    double? cpuUsage,
    double? memoryUsageMb,
    int? databaseQueryTime,
    double? uptime,
  }) {
    return PerformanceMetricsModel(
      timestamp: timestamp ?? this.timestamp,
      apiLatencyMs: apiLatencyMs ?? this.apiLatencyMs,
      appCrashRate: appCrashRate ?? this.appCrashRate,
      errorCount: errorCount ?? this.errorCount,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsageMb: memoryUsageMb ?? this.memoryUsageMb,
      databaseQueryTime: databaseQueryTime ?? this.databaseQueryTime,
      uptime: uptime ?? this.uptime,
    );
  }

  @override
  List<Object?> get props => [
    timestamp,
    apiLatencyMs,
    appCrashRate,
    errorCount,
    cpuUsage,
    memoryUsageMb,
    databaseQueryTime,
    uptime,
  ];
}

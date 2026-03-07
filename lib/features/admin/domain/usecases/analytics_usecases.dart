import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/admin/data/models/analytics_model.dart';

/// Use case for getting platform overview analytics
class GetPlatformOverviewUsecase
    implements UsecaseWithoutParms<PlatformOverviewModel> {
  final IAnalyticsRepository _repository;

  GetPlatformOverviewUsecase({required IAnalyticsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PlatformOverviewModel>> call() {
    return _repository.getOverview();
  }
}

/// Parameters for GetUserAnalyticsUsecase
class GetUserAnalyticsParams extends Equatable {
  final String period; // daily, weekly, monthly

  const GetUserAnalyticsParams({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Use case for getting user growth analytics
class GetUserAnalyticsUsecase
    implements UsecaseWithParms<List<UserGrowthModel>, GetUserAnalyticsParams> {
  final IAnalyticsRepository _repository;

  GetUserAnalyticsUsecase({required IAnalyticsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<UserGrowthModel>>> call(
    GetUserAnalyticsParams params,
  ) {
    return _repository.getUserAnalytics(params.period);
  }
}

/// Parameters for GetTripAnalyticsUsecase
class GetTripAnalyticsParams extends Equatable {
  final String period; // daily, weekly, monthly

  const GetTripAnalyticsParams({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Use case for getting trip statistics analytics
class GetTripAnalyticsUsecase
    implements UsecaseWithParms<List<TripStatsModel>, GetTripAnalyticsParams> {
  final IAnalyticsRepository _repository;

  GetTripAnalyticsUsecase({required IAnalyticsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<TripStatsModel>>> call(
    GetTripAnalyticsParams params,
  ) {
    return _repository.getTripAnalytics(params.period);
  }
}

/// Parameters for GetMatchAnalyticsUsecase
class GetMatchAnalyticsParams extends Equatable {
  final String period; // daily, weekly, monthly

  const GetMatchAnalyticsParams({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Use case for getting match statistics analytics
class GetMatchAnalyticsUsecase
    implements
        UsecaseWithParms<List<MatchStatsModel>, GetMatchAnalyticsParams> {
  final IAnalyticsRepository _repository;

  GetMatchAnalyticsUsecase({required IAnalyticsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<MatchStatsModel>>> call(
    GetMatchAnalyticsParams params,
  ) {
    return _repository.getMatchAnalytics(params.period);
  }
}

/// Use case for getting performance metrics
class GetPerformanceMetricsUsecase
    implements UsecaseWithoutParms<PerformanceMetricsModel> {
  final IAnalyticsRepository _repository;

  GetPerformanceMetricsUsecase({required IAnalyticsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PerformanceMetricsModel>> call() {
    return _repository.getPerformanceMetrics();
  }
}

/// Abstract repository interface for analytics
abstract interface class IAnalyticsRepository {
  /// Get platform overview statistics
  Future<Either<Failure, PlatformOverviewModel>> getOverview();

  /// Get user growth analytics for specified period
  Future<Either<Failure, List<UserGrowthModel>>> getUserAnalytics(
    String period,
  );

  /// Get trip statistics analytics for specified period
  Future<Either<Failure, List<TripStatsModel>>> getTripAnalytics(String period);

  /// Get match statistics analytics for specified period
  Future<Either<Failure, List<MatchStatsModel>>> getMatchAnalytics(
    String period,
  );

  /// Get system performance metrics
  Future<Either<Failure, PerformanceMetricsModel>> getPerformanceMetrics();
}

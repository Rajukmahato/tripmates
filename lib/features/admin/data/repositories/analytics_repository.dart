import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/admin/data/datasources/analytics_remote_datasource.dart';
import 'package:tripmates/features/admin/data/models/analytics_model.dart';
import 'package:tripmates/features/admin/domain/usecases/analytics_usecases.dart';

/// Riverpod provider for analytics repository
final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  final remoteDataSource = ref.read(analyticsRemoteDataSourceProvider);
  return AnalyticsRepository(remoteDataSource: remoteDataSource);
});

/// Implementation of analytics repository
class AnalyticsRepository implements IAnalyticsRepository {
  final IAnalyticsRemoteDataSource _remoteDataSource;

  AnalyticsRepository({required IAnalyticsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, PlatformOverviewModel>> getOverview() async {
    try {
      final result = await _remoteDataSource.getOverview();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserGrowthModel>>> getUserAnalytics(
    String period,
  ) async {
    try {
      final result = await _remoteDataSource.getUserAnalytics(period);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TripStatsModel>>> getTripAnalytics(
    String period,
  ) async {
    try {
      final result = await _remoteDataSource.getTripAnalytics(period);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MatchStatsModel>>> getMatchAnalytics(
    String period,
  ) async {
    try {
      final result = await _remoteDataSource.getMatchAnalytics(period);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PerformanceMetricsModel>>
  getPerformanceMetrics() async {
    try {
      final result = await _remoteDataSource.getPerformanceMetrics();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }
}

/// Riverpod providers for use cases
final getPlatformOverviewUsecaseProvider = Provider<GetPlatformOverviewUsecase>(
  (ref) {
    final repository = ref.read(analyticsRepositoryProvider);
    return GetPlatformOverviewUsecase(repository: repository);
  },
);

final getUserAnalyticsUsecaseProvider = Provider<GetUserAnalyticsUsecase>((
  ref,
) {
  final repository = ref.read(analyticsRepositoryProvider);
  return GetUserAnalyticsUsecase(repository: repository);
});

final getTripAnalyticsUsecaseProvider = Provider<GetTripAnalyticsUsecase>((
  ref,
) {
  final repository = ref.read(analyticsRepositoryProvider);
  return GetTripAnalyticsUsecase(repository: repository);
});

final getMatchAnalyticsUsecaseProvider = Provider<GetMatchAnalyticsUsecase>((
  ref,
) {
  final repository = ref.read(analyticsRepositoryProvider);
  return GetMatchAnalyticsUsecase(repository: repository);
});

final getPerformanceMetricsUsecaseProvider =
    Provider<GetPerformanceMetricsUsecase>((ref) {
      final repository = ref.read(analyticsRepositoryProvider);
      return GetPerformanceMetricsUsecase(repository: repository);
    });

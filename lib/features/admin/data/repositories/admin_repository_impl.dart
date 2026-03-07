import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:tripmates/features/admin/domain/entities/admin_report_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_trip_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_user_entity.dart';
import 'package:tripmates/features/admin/domain/repositories/admin_repository.dart';

/// Repository implementation for admin operations
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AdminStatsEntity>> getOverviewStats() async {
    try {
      final stats = await _remoteDataSource.getOverviewStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<AdminUserEntity>>> getAllUsers() async {
    try {
      final users = await _remoteDataSource.getAllUsers();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getUserById(String userId) async {
    try {
      final user = await _remoteDataSource.getUserById(userId);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleUserStatus(
    String userId,
    bool isActive,
  ) async {
    try {
      final result = await _remoteDataSource.toggleUserStatus(userId, isActive);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String userId) async {
    try {
      final result = await _remoteDataSource.deleteUser(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<AdminTripEntity>>> getAllTrips() async {
    try {
      final trips = await _remoteDataSource.getAllTrips();
      return Right(trips);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AdminTripEntity>> getTripById(String tripId) async {
    try {
      final trip = await _remoteDataSource.getTripById(tripId);
      return Right(trip);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleTripStatus(
    String tripId,
    bool isActive,
  ) async {
    try {
      final result = await _remoteDataSource.toggleTripStatus(tripId, isActive);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> featureTrip(
    String tripId,
    bool isFeatured,
  ) async {
    try {
      final result = await _remoteDataSource.featureTrip(tripId, isFeatured);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTrip(String tripId) async {
    try {
      final result = await _remoteDataSource.deleteTrip(tripId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<AdminReportEntity>>> getAllReports() async {
    try {
      final reports = await _remoteDataSource.getAllReports();
      return Right(reports);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AdminReportEntity>> getReportById(
    String reportId,
  ) async {
    try {
      final report = await _remoteDataSource.getReportById(reportId);
      return Right(report);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> reviewReport(
    String reportId,
    String status,
    String? notes,
  ) async {
    try {
      final result = await _remoteDataSource.reviewReport(
        reportId,
        status,
        notes,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> resolveReport(String reportId) async {
    try {
      final result = await _remoteDataSource.resolveReport(reportId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    }
  }
}

/// Provider - Override the placeholder from usecases
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final remoteDataSource = ref.watch(adminRemoteDataSourceProvider);
  return AdminRepositoryImpl(remoteDataSource);
});

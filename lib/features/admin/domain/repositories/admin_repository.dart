import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/admin/domain/entities/admin_report_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_trip_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_user_entity.dart';

/// Abstract repository for admin operations
abstract interface class AdminRepository {
  // Dashboard & Analytics
  Future<Either<Failure, AdminStatsEntity>> getOverviewStats();

  // User Management
  Future<Either<Failure, List<AdminUserEntity>>> getAllUsers();
  Future<Either<Failure, AdminUserEntity>> getUserById(String userId);
  Future<Either<Failure, bool>> toggleUserStatus(String userId, bool isActive);
  Future<Either<Failure, bool>> deleteUser(String userId);

  // Trip Management
  Future<Either<Failure, List<AdminTripEntity>>> getAllTrips();
  Future<Either<Failure, AdminTripEntity>> getTripById(String tripId);
  Future<Either<Failure, bool>> toggleTripStatus(String tripId, bool isActive);
  Future<Either<Failure, bool>> featureTrip(String tripId, bool isFeatured);
  Future<Either<Failure, bool>> deleteTrip(String tripId);

  // Report Management
  Future<Either<Failure, List<AdminReportEntity>>> getAllReports();
  Future<Either<Failure, AdminReportEntity>> getReportById(String reportId);
  Future<Either<Failure, bool>> reviewReport(
    String reportId,
    String status,
    String? notes,
  );
  Future<Either<Failure, bool>> resolveReport(String reportId);
}

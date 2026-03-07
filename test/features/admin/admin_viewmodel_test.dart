import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/admin/domain/entities/admin_report_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_trip_entity.dart';
import 'package:tripmates/features/admin/domain/entities/admin_user_entity.dart';
import 'package:tripmates/features/admin/domain/usecases/get_all_admin_reports_usecase.dart';
import 'package:tripmates/features/admin/domain/usecases/get_all_admin_trips_usecase.dart';
import 'package:tripmates/features/admin/domain/usecases/get_all_users_usecase.dart';
import 'package:tripmates/features/admin/domain/usecases/get_overview_stats_usecase.dart';

class MockGetOverviewStatsUseCase extends Mock
    implements GetOverviewStatsUseCase {}

class MockGetAllUsersUseCase extends Mock implements GetAllUsersUseCase {}

class MockGetAllAdminTripsUseCase extends Mock
    implements GetAllAdminTripsUseCase {}

class MockGetAllAdminReportsUseCase extends Mock
    implements GetAllAdminReportsUseCase {}

void main() {
  group('AdminViewmodel', () {
    late MockGetOverviewStatsUseCase mockGetOverviewStatsUseCase;
    late MockGetAllUsersUseCase mockGetAllUsersUseCase;
    late MockGetAllAdminTripsUseCase mockGetAllAdminTripsUseCase;
    late MockGetAllAdminReportsUseCase mockGetAllAdminReportsUseCase;

    final tAdminStatsEntity = AdminStatsEntity(
      totalUsers: 150,
      activeUsers: 120,
      totalTrips: 45,
      activeTrips: 30,
      totalReports: 12,
      pendingReports: 5,
      totalReviews: 300,
      totalMatches: 88,
    );

    final tAdminUserEntity = AdminUserEntity(
      id: 'user1',
      fullName: 'John Doe',
      email: 'john@example.com',
      isActive: true,
      isVerified: true,
      role: 'user',
      tripsCreated: 5,
      tripsJoined: 10,
      reportsReceived: 2,
      createdAt: DateTime(2024, 1, 1),
    );

    final tAdminTripEntity = AdminTripEntity(
      id: 'trip1',
      tripName: 'Paris Trip',
      destination: 'Paris, France',
      creatorId: 'user1',
      creatorName: 'John Doe',
      status: 'planned',
      startDate: DateTime(2024, 2, 1),
      endDate: DateTime(2024, 2, 10),
      participantsCount: 8,
      maxParticipants: 10,
      reportsCount: 0,
      isFeatured: false,
      isActive: true,
      createdAt: DateTime(2024, 2, 1),
    );

    final tAdminReportEntity = AdminReportEntity(
      id: 'report1',
      reporterId: 'user2',
      reporterName: 'Jane Smith',
      reportedEntityType: 'user',
      reportedEntityId: 'user3',
      reason: 'Inappropriate behavior',
      status: 'pending',
      createdAt: DateTime(2024, 2, 15),
    );

    setUp(() {
      mockGetOverviewStatsUseCase = MockGetOverviewStatsUseCase();
      mockGetAllUsersUseCase = MockGetAllUsersUseCase();
      mockGetAllAdminTripsUseCase = MockGetAllAdminTripsUseCase();
      mockGetAllAdminReportsUseCase = MockGetAllAdminReportsUseCase();
    });

    test('should load stats successfully', () async {
      when(
        () => mockGetOverviewStatsUseCase(),
      ).thenAnswer((_) async => Right(tAdminStatsEntity));

      final result = await mockGetOverviewStatsUseCase();

      expect(result, isA<Right<Failure, AdminStatsEntity>>());
      verify(() => mockGetOverviewStatsUseCase()).called(1);
    });

    test('should handle stats load failure', () async {
      final failure = ApiFailure(message: 'Failed to load stats');
      when(
        () => mockGetOverviewStatsUseCase(),
      ).thenAnswer((_) async => Left(failure));

      final result = await mockGetOverviewStatsUseCase();

      expect(result, isA<Left<Failure, AdminStatsEntity>>());
    });

    test('should load all users successfully', () async {
      when(
        () => mockGetAllUsersUseCase(),
      ).thenAnswer((_) async => Right([tAdminUserEntity]));

      final result = await mockGetAllUsersUseCase();

      expect(result, isA<Right<Failure, List<AdminUserEntity>>>());
      final users = (result as Right).value as List<AdminUserEntity>;
      expect(users.length, equals(1));
    });

    test('should handle users load failure', () async {
      final failure = ApiFailure(message: 'Failed to load users');
      when(
        () => mockGetAllUsersUseCase(),
      ).thenAnswer((_) async => Left(failure));

      final result = await mockGetAllUsersUseCase();

      expect(result, isA<Left<Failure, List<AdminUserEntity>>>());
    });

    test('should load all admin trips successfully', () async {
      when(
        () => mockGetAllAdminTripsUseCase(),
      ).thenAnswer((_) async => Right([tAdminTripEntity]));

      final result = await mockGetAllAdminTripsUseCase();

      expect(result, isA<Right<Failure, List<AdminTripEntity>>>());
      final trips = (result as Right).value as List<AdminTripEntity>;
      expect(trips.length, equals(1));
    });

    test('should handle trips load failure', () async {
      final failure = ApiFailure(message: 'Failed to load trips');
      when(
        () => mockGetAllAdminTripsUseCase(),
      ).thenAnswer((_) async => Left(failure));

      final result = await mockGetAllAdminTripsUseCase();

      expect(result, isA<Left<Failure, List<AdminTripEntity>>>());
    });

    test('should load all reports successfully', () async {
      when(
        () => mockGetAllAdminReportsUseCase(),
      ).thenAnswer((_) async => Right([tAdminReportEntity]));

      final result = await mockGetAllAdminReportsUseCase();

      expect(result, isA<Right<Failure, List<AdminReportEntity>>>());
      final reports = (result as Right).value as List<AdminReportEntity>;
      expect(reports.length, equals(1));
    });

    test('should handle reports load failure', () async {
      final failure = ApiFailure(message: 'Failed to load reports');
      when(
        () => mockGetAllAdminReportsUseCase(),
      ).thenAnswer((_) async => Left(failure));

      final result = await mockGetAllAdminReportsUseCase();

      expect(result, isA<Left<Failure, List<AdminReportEntity>>>());
    });
  });
}

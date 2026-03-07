import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/usecases/create_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_all_trips_usecase.dart';

class MockTripRepository extends Mock implements ITripRepository {}

class FakeTripEntity extends Fake implements TripEntity {
  @override
  final String? tripId = 'trip1';
  @override
  final String tripName = 'Test';
  @override
  final String destination = 'Test';
  @override
  final String? createdBy = 'user1';
  @override
  final DateTime startDate = DateTime(2024, 1, 1);
  @override
  final DateTime endDate = DateTime(2024, 1, 10);
  @override
  final TripStatus status = TripStatus.planned;
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTripEntity());
  });

  group('Trip Usecases', () {
    late MockTripRepository mockTripRepository;

    final tTripEntity = TripEntity(
      tripId: 'trip1',
      tripName: 'Paris Adventure',
      createdBy: 'user1',
      destination: 'Paris, France',
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 6, 10),
      description: 'Amazing trip to Paris',
      status: TripStatus.planned,
      media: 'assets/images/paris.jpg',
    );

    setUp(() {
      mockTripRepository = MockTripRepository();
    });

    test('should return list of trips when repository call succeeds', () async {
      when(
        () => mockTripRepository.getAllTrips(),
      ).thenAnswer((_) async => Right([tTripEntity]));

      final getAllTripsUsecase = GetAllTripsUsecase(
        tripRepository: mockTripRepository,
      );
      final result = await getAllTripsUsecase();

      expect(result, isA<Right<Failure, List<TripEntity>>>());
      final trips = (result as Right).value;
      expect(trips.length, equals(1));
      expect(trips.first.tripName, equals('Paris Adventure'));
    });

    test('should return empty list when no trips available', () async {
      when(
        () => mockTripRepository.getAllTrips(),
      ).thenAnswer((_) async => const Right([]));

      final getAllTripsUsecase = GetAllTripsUsecase(
        tripRepository: mockTripRepository,
      );
      final result = await getAllTripsUsecase();

      final trips = (result as Right).value;
      expect(trips, isEmpty);
    });

    test('should return failure when repository fails', () async {
      final failure = ApiFailure(message: 'Network error');
      when(
        () => mockTripRepository.getAllTrips(),
      ).thenAnswer((_) async => Left(failure));

      final getAllTripsUsecase = GetAllTripsUsecase(
        tripRepository: mockTripRepository,
      );
      final result = await getAllTripsUsecase();

      expect(result, isA<Left<Failure, List<TripEntity>>>());
    });

    test('should create trip successfully', () async {
      when(
        () => mockTripRepository.createTrip(any()),
      ).thenAnswer((_) async => const Right(true));

      final createTripUsecase = CreateTripUsecase(
        tripRepository: mockTripRepository,
      );
      final params = CreateTripParams(
        tripName: 'New Trip',
        destination: 'New Destination',
        startDate: DateTime(2024, 8, 1),
        endDate: DateTime(2024, 8, 10),
        description: 'Trip description',
        status: TripStatus.planned,
        media: 'assets/images/trip.jpg',
        userId: 'user1',
      );

      final result = await createTripUsecase(params);

      expect(result, isA<Right<Failure, bool>>());
      expect((result as Right).value, isTrue);
    });

    test('should return failure when create trip fails', () async {
      final failure = ApiFailure(message: 'Failed to create trip');
      when(
        () => mockTripRepository.createTrip(any()),
      ).thenAnswer((_) async => Left(failure));

      final createTripUsecase = CreateTripUsecase(
        tripRepository: mockTripRepository,
      );
      final params = CreateTripParams(
        tripName: 'New Trip',
        destination: 'New Destination',
        startDate: DateTime(2024, 8, 1),
        endDate: DateTime(2024, 8, 10),
        description: 'Trip description',
        status: TripStatus.planned,
        media: 'assets/images/trip.jpg',
        userId: 'user1',
      );

      final result = await createTripUsecase(params);

      expect(result, isA<Left<Failure, bool>>());
    });
  });
}

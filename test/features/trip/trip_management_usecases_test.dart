import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/usecases/delete_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/update_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_my_trips_usecase.dart';

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

  group('Trip Management Usecases', () {
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

    group('DeleteTripUsecase', () {
      test('should delete trip successfully', () async {
        when(
          () => mockTripRepository.deleteTrip(any()),
        ).thenAnswer((_) async => const Right(true));

        final deleteTripUsecase = DeleteTripUsecase(
          tripRepository: mockTripRepository,
        );
        const params = DeleteTripParams(tripId: 'trip1');

        final result = await deleteTripUsecase(params);

        expect(result, isA<Right<Failure, bool>>());
        expect((result as Right).value, isTrue);
        verify(() => mockTripRepository.deleteTrip('trip1')).called(1);
      });

      test('should return failure when delete trip fails', () async {
        final failure = ApiFailure(message: 'Failed to delete trip');
        when(
          () => mockTripRepository.deleteTrip(any()),
        ).thenAnswer((_) async => Left(failure));

        final deleteTripUsecase = DeleteTripUsecase(
          tripRepository: mockTripRepository,
        );
        const params = DeleteTripParams(tripId: 'trip1');

        final result = await deleteTripUsecase(params);

        expect(result, isA<Left<Failure, bool>>());
        expect((result as Left).value, failure);
      });
    });

    group('UpdateTripUsecase', () {
      test('should update trip successfully', () async {
        when(
          () => mockTripRepository.updateTrip(any()),
        ).thenAnswer((_) async => const Right(true));

        final updateTripUsecase = UpdateTripUsecase(
          tripRepository: mockTripRepository,
        );
        final params = UpdateTripParams(
          tripId: 'trip1',
          tripName: 'Updated Trip',
          destination: 'Updated Destination',
          startDate: DateTime(2024, 8, 1),
          endDate: DateTime(2024, 8, 10),
          status: TripStatus.planned,
          description: 'Updated description',
        );

        final result = await updateTripUsecase(params);

        expect(result, isA<Right<Failure, bool>>());
        expect((result as Right).value, isTrue);
        verify(() => mockTripRepository.updateTrip(any())).called(1);
      });

      test('should return failure when update trip fails', () async {
        final failure = ApiFailure(message: 'Failed to update trip');
        when(
          () => mockTripRepository.updateTrip(any()),
        ).thenAnswer((_) async => Left(failure));

        final updateTripUsecase = UpdateTripUsecase(
          tripRepository: mockTripRepository,
        );
        final params = UpdateTripParams(
          tripId: 'trip1',
          tripName: 'Updated Trip',
          destination: 'Updated Destination',
          startDate: DateTime(2024, 8, 1),
          endDate: DateTime(2024, 8, 10),
          status: TripStatus.planned,
        );

        final result = await updateTripUsecase(params);

        expect(result, isA<Left<Failure, bool>>());
        expect((result as Left).value, failure);
      });
    });

    group('GetMyTripsUsecase', () {
      test('should return user\'s trips successfully', () async {
        when(
          () => mockTripRepository.getTripsByUser(any()),
        ).thenAnswer((_) async => Right([tTripEntity]));

        final getMyTripsUsecase = GetMyTripsUsecase(
          tripRepository: mockTripRepository,
        );
        const params = GetMyTripsParams(userId: 'user1');

        final result = await getMyTripsUsecase(params);

        expect(result, isA<Right<Failure, List<TripEntity>>>());
        final trips = (result as Right).value;
        expect(trips.length, equals(1));
        expect(trips.first.tripName, equals('Paris Adventure'));
        verify(() => mockTripRepository.getTripsByUser('user1')).called(1);
      });
    });
  });
}

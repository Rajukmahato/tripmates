import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/trip/domain/usecases/create_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/delete_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_all_trips_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_my_trips_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/update_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/presentation/state/trip_state.dart';

final tripViewModelProvider = NotifierProvider<TripViewModel, TripState>(
  TripViewModel.new,
);

class TripViewModel extends Notifier<TripState> {
  late final GetAllTripsUsecase _getAllTripsUsecase;
  late final GetMyTripsUsecase _getMyTripsUsecase;
  late final CreateTripUsecase _createTripUsecase;
  late final UpdateTripUsecase _updateTripUsecase;
  late final DeleteTripUsecase _deleteTripUsecase;

  @override
  TripState build() {
    _getAllTripsUsecase = ref.read(getAllTripsUsecaseProvider);
    _getMyTripsUsecase = ref.read(getMyTripsUsecaseProvider);
    _createTripUsecase = ref.read(createTripUsecaseProvider);
    _updateTripUsecase = ref.read(updateTripUsecaseProvider);
    _deleteTripUsecase = ref.read(deleteTripUsecaseProvider);
    return const TripState();
  }

  Future<void> getAllTrips() async {
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _getAllTripsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: failure.message,
      ),
      (trips) =>
          state = state.copyWith(status: TripStateStatus.loaded, trips: trips),
    );
  }

  Future<void> getMyTrips(String userId) async {
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _getMyTripsUsecase(GetMyTripsParams(userId: userId));

    result.fold(
      (failure) => state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: failure.message,
      ),
      (trips) =>
          state = state.copyWith(status: TripStateStatus.loaded, trips: trips),
    );
  }

  Future<void> createTrip({
    required String tripName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required TripStatus status,
    String? description,
    String? category,
    String? media,
    List<String>? destinationIds,
    required String userId,
  }) async {
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _createTripUsecase(
      CreateTripParams(
        tripName: tripName,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        status: status,
        description: description,
        category: category,
        media: media,
        destinationIds: destinationIds,
        userId: userId,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: TripStateStatus.created);
        getAllTrips();
      },
    );
  }

  Future<void> updateTrip({
    required String tripId,
    required String tripName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required TripStatus status,
    String? description,
    String? category,
    String? media,
    List<String>? destinationIds,
  }) async {
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _updateTripUsecase(
      UpdateTripParams(
        tripId: tripId,
        tripName: tripName,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        status: status,
        description: description,
        category: category,
        media: media,
        destinationIds: destinationIds,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: TripStateStatus.updated);
        getAllTrips();
      },
    );
  }

  Future<void> deleteTrip(String tripId) async {
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _deleteTripUsecase(DeleteTripParams(tripId: tripId));

    result.fold(
      (failure) => state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: TripStateStatus.deleted);
        getAllTrips();
      },
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';

enum TripStateStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

class TripState extends Equatable {
  final TripStateStatus status;
  final List<TripEntity> trips;
  final TripEntity? selectedTrip;
  final String? errorMessage;

  const TripState({
    this.status = TripStateStatus.initial,
    this.trips = const [],
    this.selectedTrip,
    this.errorMessage,
  });

  TripState copyWith({
    TripStateStatus? status,
    List<TripEntity>? trips,
    TripEntity? selectedTrip,
    String? errorMessage,
  }) {
    return TripState(
      status: status ?? this.status,
      trips: trips ?? this.trips,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, trips, selectedTrip, errorMessage];
}

import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';

enum UserTripPhase { planned, ongoing, done }

class MyTripsSections {
  final List<TripEntity> planned;
  final List<TripEntity> ongoing;
  final List<TripEntity> completed;

  const MyTripsSections({
    required this.planned,
    required this.ongoing,
    required this.completed,
  });
}

bool isCreatorOrMember(TripEntity trip, String currentUserId) {
  if (currentUserId.isEmpty) {
    return false;
  }

  final isCreator = trip.createdBy == currentUserId;
  final isMember =
      trip.members?.any((member) => member.userId == currentUserId) ?? false;

  return isCreator || isMember;
}

List<TripEntity> getUserTripsFromAllTrips(
  List<TripEntity> allTrips,
  String currentUserId,
) {
  return allTrips
      .where((trip) => isCreatorOrMember(trip, currentUserId))
      .toList();
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

UserTripPhase getUserTripPhase(TripEntity trip, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final startDate = _dateOnly(trip.startDate);
  final endDate = _dateOnly(trip.endDate);

  if (today.isBefore(startDate)) {
    return UserTripPhase.planned;
  }

  if (today.isAfter(endDate)) {
    return UserTripPhase.done;
  }

  return UserTripPhase.ongoing;
}

MyTripsSections getMyTripsSections(List<TripEntity> allTrips, String userId) {
  final userTrips = getUserTripsFromAllTrips(allTrips, userId);

  final planned = <TripEntity>[];
  final ongoing = <TripEntity>[];
  final completed = <TripEntity>[];

  for (final trip in userTrips) {
    final phase = getUserTripPhase(trip);
    switch (phase) {
      case UserTripPhase.planned:
        planned.add(trip);
      case UserTripPhase.ongoing:
        ongoing.add(trip);
      case UserTripPhase.done:
        completed.add(trip);
    }
  }

  return MyTripsSections(
    planned: planned,
    ongoing: ongoing,
    completed: completed,
  );
}

import 'package:tripmates/features/trip/data/models/trip_hive_model.dart';

abstract interface class ITripDataSource {
  Future<bool> createTrip(TripHiveModel trip);
  Future<List<TripHiveModel>> getAllTrips();
  Future<TripHiveModel?> getTripById(String tripId);
  Future<bool> updateTrip(TripHiveModel trip);
  Future<bool> deleteTrip(String tripId);
  Future<List<TripHiveModel>> getMyTrips(String userId);
}

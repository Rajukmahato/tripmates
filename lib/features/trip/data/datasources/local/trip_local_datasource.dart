import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/services/hive/hive_service.dart';
import 'package:tripmates/features/trip/data/datasources/trip_datasource.dart';
import 'package:tripmates/features/trip/data/models/trip_hive_model.dart';

final tripLocalDatasourceProvider = Provider<ITripDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return TripLocalDatasource(hiveService: hiveService);
});

class TripLocalDatasource implements ITripDataSource {
  final HiveService _hiveService;

  TripLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> createTrip(TripHiveModel trip) async {
    await _hiveService.createTrip(trip);
    return true;
  }

  @override
  Future<bool> deleteTrip(String tripId) async {
    await _hiveService.deleteTrip(tripId);
    return true;
  }

  @override
  Future<List<TripHiveModel>> getAllTrips() async {
    return await _hiveService.getAllTrips();
  }

  @override
  Future<TripHiveModel?> getTripById(String tripId) async {
    return await _hiveService.getTripById(tripId);
  }

  @override
  Future<bool> updateTrip(TripHiveModel trip) async {
    return await _hiveService.updateTrip(trip);
  }

  @override
  Future<List<TripHiveModel>> getMyTrips(String userId) async {
    final allTrips = await _hiveService.getAllTrips();
    return allTrips.where((trip) => trip.createdBy == userId).toList();
  }
}

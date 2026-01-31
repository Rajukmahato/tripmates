import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/trip/data/models/trip_api_model.dart';

final tripRemoteDatasourceProvider = Provider<ITripRemoteDataSource>((ref) {
  return TripRemoteDatasource();
});

abstract interface class ITripRemoteDataSource {
  Future<List<TripApiModel>> getAllTrips();
  Future<TripApiModel> getTripById(String tripId);
}

class TripRemoteDatasource implements ITripRemoteDataSource {
  @override
  Future<List<TripApiModel>> getAllTrips() async {
    // TODO: Implement API call
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<TripApiModel> getTripById(String tripId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}

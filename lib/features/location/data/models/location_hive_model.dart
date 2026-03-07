import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/features/location/domain/entities/location_entity.dart';

part 'location_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.locationTypeId)
class LocationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String userName;

  @HiveField(3)
  final String tripId;

  @HiveField(4)
  final double latitude;

  @HiveField(5)
  final double longitude;

  @HiveField(6)
  final String timestamp;

  @HiveField(7)
  final double? accuracy;

  LocationHiveModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
  });

  factory LocationHiveModel.fromEntity(LocationEntity entity) {
    return LocationHiveModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      tripId: entity.tripId,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp.toIso8601String(),
      accuracy: entity.accuracy,
    );
  }

  LocationEntity toEntity() {
    return LocationEntity(
      id: id,
      userId: userId,
      userName: userName,
      tripId: tripId,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
      accuracy: accuracy,
    );
  }

  @override
  String toString() {
    return 'LocationHiveModel(id: $id, userId: $userId, userName: $userName, tripId: $tripId, lat: $latitude, lng: $longitude, timestamp: $timestamp, accuracy: $accuracy)';
  }
}

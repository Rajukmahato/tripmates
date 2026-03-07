import 'package:tripmates/features/location/domain/entities/location_entity.dart';

class LocationApiModel {
  final String id;
  final String userId;
  final String userName;
  final String tripId;
  final double latitude;
  final double longitude;
  final String timestamp;
  final double? accuracy;

  LocationApiModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
  });

  factory LocationApiModel.fromJson(Map<String, dynamic> json) {
    return LocationApiModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      tripId: json['tripId'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'tripId': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      if (accuracy != null) 'accuracy': accuracy,
    };
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

  factory LocationApiModel.fromEntity(LocationEntity entity) {
    return LocationApiModel(
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
}

import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String tripId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy;

  const LocationEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
  });

  LocationEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? tripId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? accuracy,
  }) {
    return LocationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      tripId: tripId ?? this.tripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    tripId,
    latitude,
    longitude,
    timestamp,
    accuracy,
  ];
}

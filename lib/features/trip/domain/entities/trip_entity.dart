import 'package:equatable/equatable.dart';

enum TripStatus { planned, ongoing, completed }

class TripEntity extends Equatable {
  final String? tripId;
  final String? createdBy;
  final String tripName;
  final String? description;
  final String destination;
  final String? category;
  final DateTime startDate;
  final DateTime endDate;
  final String? media;
  final String? mediaType;
  final TripStatus status;
  final List<String>? destinationIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TripEntity({
    this.tripId,
    this.createdBy,
    required this.tripName,
    this.description,
    required this.destination,
    this.category,
    required this.startDate,
    required this.endDate,
    this.media,
    this.mediaType,
    this.status = TripStatus.planned,
    this.destinationIds,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    tripId,
    createdBy,
    tripName,
    description,
    destination,
    category,
    startDate,
    endDate,
    media,
    mediaType,
    status,
    destinationIds,
    createdAt,
    updatedAt,
  ];
}

import 'package:equatable/equatable.dart';

class DestinationEntity extends Equatable {
  final String? destinationId;
  final String? tripId;
  final String? createdBy;
  final String? category;
  final String destinationName;
  final String? description;
  final String location;
  final String? media;
  final String? mediaType;
  final DateTime? visitDate;
  final bool isVisited;
  final double? budget;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DestinationEntity({
    this.destinationId,
    this.tripId,
    this.createdBy,
    this.category,
    required this.destinationName,
    this.description,
    required this.location,
    this.media,
    this.mediaType,
    this.visitDate,
    this.isVisited = false,
    this.budget,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    destinationId,
    tripId,
    createdBy,
    category,
    destinationName,
    description,
    location,
    media,
    mediaType,
    visitDate,
    isVisited,
    budget,
    notes,
    createdAt,
    updatedAt,
  ];
}

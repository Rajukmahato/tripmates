import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import '../../../../core/api/api_endpoints.dart';

String? _resolveMedia(String? media) {
  if (media == null || media.isEmpty) return null;
  if (media.startsWith('http')) return media;
  final cleaned = media.startsWith('/') ? media.substring(1) : media;
  return '${ApiEndpoints.baseOrigin}/$cleaned';
}

class TripApiModel {
  final String? id;
  final String? createdBy;
  final String tripName;
  final String? description;
  final String destination;
  final String? category;
  final DateTime startDate;
  final DateTime endDate;
  final String? media;
  final String? mediaType;
  final String status;
  final List<String>? destinationIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripApiModel({
    this.id,
    this.createdBy,
    required this.tripName,
    this.description,
    required this.destination,
    this.category,
    required this.startDate,
    required this.endDate,
    this.media,
    this.mediaType,
    this.status = 'planned',
    this.destinationIds,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripName': tripName,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (media != null) 'media': media,
      if (mediaType != null) 'mediaType': mediaType,
      if (status.isNotEmpty) 'status': status,
      if (destinationIds != null) 'destinationIds': destinationIds,
    };
  }

  factory TripApiModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value['_id'] as String?;
      return value as String?;
    }

    return TripApiModel(
      id: json['_id'] as String?,
      createdBy: extractId(json['createdBy']),
      tripName: json['tripName'] as String,
      description: json['description'] as String?,
      destination: json['destination'] as String,
      category: extractId(json['category']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      media: _resolveMedia(json['media'] as String?),
      mediaType: json['mediaType'] as String?,
      status: json['status'] as String? ?? 'planned',
      destinationIds: (json['destinationIds'] as List?)?.cast<String>(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  TripEntity toEntity() {
    return TripEntity(
      tripId: id,
      createdBy: createdBy,
      tripName: tripName,
      description: description,
      destination: destination,
      category: category,
      startDate: startDate,
      endDate: endDate,
      media: media,
      mediaType: mediaType,
      status: status == 'planned'
          ? TripStatus.planned
          : status == 'ongoing'
          ? TripStatus.ongoing
          : TripStatus.completed,
      destinationIds: destinationIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TripApiModel.fromEntity(TripEntity entity) {
    return TripApiModel(
      id: entity.tripId,
      createdBy: entity.createdBy,
      tripName: entity.tripName,
      description: entity.description,
      destination: entity.destination,
      category: entity.category,
      startDate: entity.startDate,
      endDate: entity.endDate,
      media: entity.media,
      mediaType: entity.mediaType,
      status: entity.status.toString().split('.').last,
      destinationIds: entity.destinationIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<TripEntity> toEntityList(List<TripApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

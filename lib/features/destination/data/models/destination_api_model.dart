import 'package:tripmates/features/destination/domain/entities/destination_entity.dart';
import '../../../../core/api/api_endpoints.dart';

String? _resolveMedia(String? media) {
  if (media == null || media.isEmpty) return null;
  if (media.startsWith('http')) return media;
  final cleaned = media.startsWith('/') ? media.substring(1) : media;
  return '${ApiEndpoints.baseOrigin}/$cleaned';
}

class DestinationApiModel {
  final String? id;
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

  DestinationApiModel({
    this.id,
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

  Map<String, dynamic> toJson() {
    return {
      'destinationName': destinationName,
      'location': location,
      if (tripId != null) 'tripId': tripId,
      if (createdBy != null) 'createdBy': createdBy,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (media != null) 'media': media,
      if (mediaType != null) 'mediaType': mediaType,
      if (visitDate != null) 'visitDate': visitDate!.toIso8601String(),
      'isVisited': isVisited,
      if (budget != null) 'budget': budget,
      if (notes != null) 'notes': notes,
    };
  }

  factory DestinationApiModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value['_id'] as String?;
      return value as String?;
    }

    return DestinationApiModel(
      id: json['_id'] as String?,
      tripId: extractId(json['tripId']),
      createdBy: extractId(json['createdBy']),
      category: extractId(json['category']),
      destinationName: json['destinationName'] as String,
      description: json['description'] as String?,
      location: json['location'] as String,
      media: _resolveMedia(json['media'] as String?),
      mediaType: json['mediaType'] as String?,
      visitDate: json['visitDate'] != null
          ? DateTime.parse(json['visitDate'] as String)
          : null,
      isVisited: json['isVisited'] as bool? ?? false,
      budget: json['budget'] != null
          ? (json['budget'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  DestinationEntity toEntity() {
    return DestinationEntity(
      destinationId: id,
      tripId: tripId,
      createdBy: createdBy,
      category: category,
      destinationName: destinationName,
      description: description,
      location: location,
      media: media,
      mediaType: mediaType,
      visitDate: visitDate,
      isVisited: isVisited,
      budget: budget,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory DestinationApiModel.fromEntity(DestinationEntity entity) {
    return DestinationApiModel(
      id: entity.destinationId,
      tripId: entity.tripId,
      createdBy: entity.createdBy,
      category: entity.category,
      destinationName: entity.destinationName,
      description: entity.description,
      location: entity.location,
      media: entity.media,
      mediaType: entity.mediaType,
      visitDate: entity.visitDate,
      isVisited: entity.isVisited,
      budget: entity.budget,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<DestinationEntity> toEntityList(
    List<DestinationApiModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}

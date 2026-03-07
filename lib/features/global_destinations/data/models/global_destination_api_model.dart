import 'package:equatable/equatable.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';

/// API model for global destination data transfer
class GlobalDestinationApiModel extends Equatable {
  final String id;
  final String name;
  final String country;
  final String? description;
  final List<String>? attractions;
  final List<String>? images;
  final String? coverImage;
  final List<String>? travelTips;
  final bool isActive;
  final String? climate;
  final String? bestTimeToVisit;
  final List<String>? popularActivities;
  final String? currency;
  final String? language;
  final String? timezone;
  final double? averageRating;
  final int? reviewCount;
  final int? tripCount;
  final String? createdAt;
  final String? updatedAt;

  const GlobalDestinationApiModel({
    required this.id,
    required this.name,
    required this.country,
    this.description,
    this.attractions,
    this.images,
    this.coverImage,
    this.travelTips,
    this.isActive = true,
    this.climate,
    this.bestTimeToVisit,
    this.popularActivities,
    this.currency,
    this.language,
    this.timezone,
    this.averageRating,
    this.reviewCount,
    this.tripCount,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory GlobalDestinationApiModel.fromJson(Map<String, dynamic> json) {
    return GlobalDestinationApiModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      description: json['description'] as String?,
      attractions: json['attractions'] != null
          ? List<String>.from(json['attractions'] as List)
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      coverImage: json['coverImage'] as String?,
      travelTips: json['travelTips'] != null
          ? List<String>.from(json['travelTips'] as List)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      climate: json['climate'] as String?,
      bestTimeToVisit: json['bestTimeToVisit'] as String?,
      popularActivities: json['popularActivities'] != null
          ? List<String>.from(json['popularActivities'] as List)
          : null,
      currency: json['currency'] as String?,
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : null,
      reviewCount: json['reviewCount'] as int?,
      tripCount: json['tripCount'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'country': country,
      if (description != null) 'description': description,
      if (attractions != null) 'attractions': attractions,
      if (images != null) 'images': images,
      if (coverImage != null) 'coverImage': coverImage,
      if (travelTips != null) 'travelTips': travelTips,
      'isActive': isActive,
      if (climate != null) 'climate': climate,
      if (bestTimeToVisit != null) 'bestTimeToVisit': bestTimeToVisit,
      if (popularActivities != null) 'popularActivities': popularActivities,
      if (currency != null) 'currency': currency,
      if (language != null) 'language': language,
      if (timezone != null) 'timezone': timezone,
      if (averageRating != null) 'averageRating': averageRating,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (tripCount != null) 'tripCount': tripCount,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  /// Convert to entity
  GlobalDestinationEntity toEntity() {
    return GlobalDestinationEntity(
      id: id,
      name: name,
      country: country,
      description: description,
      attractions: attractions,
      images: images,
      coverImage: coverImage,
      travelTips: travelTips,
      isActive: isActive,
      climate: climate,
      bestTimeToVisit: bestTimeToVisit,
      popularActivities: popularActivities,
      currency: currency,
      language: language,
      timezone: timezone,
      averageRating: averageRating,
      reviewCount: reviewCount,
      tripCount: tripCount,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Create from entity
  factory GlobalDestinationApiModel.fromEntity(GlobalDestinationEntity entity) {
    return GlobalDestinationApiModel(
      id: entity.id,
      name: entity.name,
      country: entity.country,
      description: entity.description,
      attractions: entity.attractions,
      images: entity.images,
      coverImage: entity.coverImage,
      travelTips: entity.travelTips,
      isActive: entity.isActive,
      climate: entity.climate,
      bestTimeToVisit: entity.bestTimeToVisit,
      popularActivities: entity.popularActivities,
      currency: entity.currency,
      language: entity.language,
      timezone: entity.timezone,
      averageRating: entity.averageRating,
      reviewCount: entity.reviewCount,
      tripCount: entity.tripCount,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    country,
    description,
    attractions,
    images,
    coverImage,
    travelTips,
    isActive,
    climate,
    bestTimeToVisit,
    popularActivities,
    currency,
    language,
    timezone,
    averageRating,
    reviewCount,
    tripCount,
    createdAt,
    updatedAt,
  ];
}

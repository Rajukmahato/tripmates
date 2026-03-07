import 'package:equatable/equatable.dart';

/// Represents a global travel destination in the catalog
/// This is different from trip destinations/waypoints
class GlobalDestinationEntity extends Equatable {
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
  final int? tripCount; // Number of trips to this destination
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GlobalDestinationEntity({
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

  /// Get the primary image for the destination
  String? get primaryImage =>
      coverImage ?? (images?.isNotEmpty == true ? images!.first : null);

  /// Get the display name with country
  String get displayName => '$name, $country';

  /// Check if destination has images
  bool get hasImages => images?.isNotEmpty == true;

  /// Check if destination has attractions
  bool get hasAttractions => attractions?.isNotEmpty == true;

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

  /// Create a copy with modified fields
  GlobalDestinationEntity copyWith({
    String? id,
    String? name,
    String? country,
    String? description,
    List<String>? attractions,
    List<String>? images,
    String? coverImage,
    List<String>? travelTips,
    bool? isActive,
    String? climate,
    String? bestTimeToVisit,
    List<String>? popularActivities,
    String? currency,
    String? language,
    String? timezone,
    double? averageRating,
    int? reviewCount,
    int? tripCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GlobalDestinationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      description: description ?? this.description,
      attractions: attractions ?? this.attractions,
      images: images ?? this.images,
      coverImage: coverImage ?? this.coverImage,
      travelTips: travelTips ?? this.travelTips,
      isActive: isActive ?? this.isActive,
      climate: climate ?? this.climate,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      popularActivities: popularActivities ?? this.popularActivities,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      tripCount: tripCount ?? this.tripCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

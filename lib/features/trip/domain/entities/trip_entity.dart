import 'package:equatable/equatable.dart';
import 'package:tripmates/features/trip/domain/entities/trip_member_entity.dart';
import 'package:tripmates/features/trip/domain/entities/itinerary_item_entity.dart';
import 'package:tripmates/features/trip/domain/entities/checklist_item_entity.dart';

enum TripStatus { planned, ongoing, completed }

class TripEntity extends Equatable {
  final String? tripId;
  final String? createdBy;
  final String? createdByName;
  final String? createdByAvatar;
  final String tripName;
  final String? description;
  final String destination;
  final String? category;
  final double? budget;
  final String? travelType;
  final int? groupSizeMin;
  final int? groupSizeMax;
  final List<String>? activities;
  final String? difficultyLevel;
  final DateTime startDate;
  final DateTime endDate;
  final String? media;
  final String? mediaType;
  final TripStatus status;
  final List<String>? destinationIds;
  final double? averageRating;
  final int? reviewCount;
  final String? groupChatId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TripMemberEntity>? members;
  final List<ItineraryItemEntity>? itinerary;
  final List<ChecklistItemEntity>? checklist;
  final String? notes;

  // Web-parity fields: Distance
  final double? distanceMin;
  final double? distanceMax;
  final String? distanceUnit;

  // Web-parity fields: Duration
  final int? durationMinHours;
  final int? durationMaxHours;

  // Web-parity fields: Physical attributes
  final String? physicalDemand;
  final String? skillLevelRequired;
  final String? fitnessLevel;

  // Web-parity fields: Group
  final int? maxMembers;
  final int? currentMembers;
  final int? favoriteCount;

  // Web-parity fields: Seasons & Elevation
  final String? bestSeason;
  final List<String>? bestMonths;
  final int? elevationMin;
  final int? elevationMax;
  final String? elevationUnit;

  // Web-parity fields: Details & Inclusions
  final List<String>? inclusions;
  final List<String>? exclusions;
  final String? mealsIncluded;
  final String? accommodationType;

  // Web-parity fields: Content
  final List<String>? highlights;
  final List<String>? keyAttractions;
  final List<String>? gallery;
  final String? videoUrl;

  // Web-parity fields: Metadata
  final bool? hasGroupChat;
  final String? emergencySupportPhone;
  final bool? isFeatured;
  final bool? isPublic;

  const TripEntity({
    this.tripId,
    this.createdBy,
    this.createdByName,
    this.createdByAvatar,
    required this.tripName,
    this.description,
    required this.destination,
    this.category,
    this.budget,
    this.travelType,
    this.groupSizeMin,
    this.groupSizeMax,
    this.activities,
    this.difficultyLevel,
    required this.startDate,
    required this.endDate,
    this.media,
    this.mediaType,
    this.status = TripStatus.planned,
    this.destinationIds,
    this.averageRating,
    this.reviewCount,
    this.groupChatId,
    this.createdAt,
    this.updatedAt,
    this.members,
    this.itinerary,
    this.checklist,
    this.notes,
    this.distanceMin,
    this.distanceMax,
    this.distanceUnit,
    this.durationMinHours,
    this.durationMaxHours,
    this.physicalDemand,
    this.skillLevelRequired,
    this.fitnessLevel,
    this.maxMembers,
    this.currentMembers,
    this.favoriteCount,
    this.bestSeason,
    this.bestMonths,
    this.elevationMin,
    this.elevationMax,
    this.elevationUnit,
    this.inclusions,
    this.exclusions,
    this.mealsIncluded,
    this.accommodationType,
    this.highlights,
    this.keyAttractions,
    this.gallery,
    this.videoUrl,
    this.hasGroupChat,
    this.emergencySupportPhone,
    this.isFeatured,
    this.isPublic,
  });

  @override
  List<Object?> get props => [
    tripId,
    distanceMin,
    distanceMax,
    distanceUnit,
    durationMinHours,
    durationMaxHours,
    physicalDemand,
    skillLevelRequired,
    fitnessLevel,
    maxMembers,
    currentMembers,
    favoriteCount,
    bestSeason,
    bestMonths,
    elevationMin,
    elevationMax,
    elevationUnit,
    inclusions,
    exclusions,
    mealsIncluded,
    accommodationType,
    highlights,
    keyAttractions,
    gallery,
    videoUrl,
    hasGroupChat,
    emergencySupportPhone,
    isFeatured,
    isPublic,
    createdBy,
    createdByName,
    createdByAvatar,
    tripName,
    description,
    destination,
    category,
    budget,
    travelType,
    groupSizeMin,
    groupSizeMax,
    activities,
    difficultyLevel,
    startDate,
    endDate,
    media,
    mediaType,
    status,
    destinationIds,
    averageRating,
    members,
    itinerary,
    checklist,
    notes,
    reviewCount,
    groupChatId,
    createdAt,
    updatedAt,
  ];
}

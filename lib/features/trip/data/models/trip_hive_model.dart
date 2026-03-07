import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:uuid/uuid.dart';

part 'trip_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.tripTypeId)
class TripHiveModel extends HiveObject {
  @HiveField(0)
  final String? tripId;

  @HiveField(1)
  final String? createdBy;

  @HiveField(2)
  final String tripName;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String destination;

  @HiveField(5)
  final String? category;

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final DateTime endDate;

  @HiveField(8)
  final String? media;

  @HiveField(9)
  final String? mediaType;

  @HiveField(10)
  final String status;

  @HiveField(11)
  final List<String>? destinationIds;

  // Web-parity fields added (HiveField 12+)
  @HiveField(12)
  final double? budget;

  @HiveField(13)
  final String? difficultyLevel;

  @HiveField(14)
  final List<String>? activities;

  @HiveField(15)
  final double? distanceMin;

  @HiveField(16)
  final double? distanceMax;

  @HiveField(17)
  final String? distanceUnit;

  @HiveField(18)
  final int? durationMinHours;

  @HiveField(19)
  final int? durationMaxHours;

  @HiveField(20)
  final String? physicalDemand;

  @HiveField(21)
  final String? skillLevelRequired;

  @HiveField(22)
  final String? fitnessLevel;

  @HiveField(23)
  final int? elevationMin;

  @HiveField(24)
  final int? elevationMax;

  @HiveField(25)
  final String? elevationUnit;

  @HiveField(26)
  final String? bestSeason;

  @HiveField(27)
  final String? mealsIncluded;

  @HiveField(28)
  final String? accommodationType;

  @HiveField(29)
  final String? videoUrl;

  @HiveField(30)
  final bool? hasGroupChat;

  @HiveField(31)
  final String? emergencySupportPhone;

  @HiveField(32)
  final bool? isFeatured;

  @HiveField(33)
  final bool? isPublic;

  @HiveField(34)
  final double? averageRating;

  @HiveField(35)
  final int? reviewCount;

  TripHiveModel({
    String? tripId,
    this.createdBy,
    required this.tripName,
    this.description,
    required this.destination,
    this.category,
    required this.startDate,
    required this.endDate,
    this.media,
    this.mediaType,
    String? status,
    this.destinationIds,
    this.budget,
    this.difficultyLevel,
    this.activities,
    this.distanceMin,
    this.distanceMax,
    this.distanceUnit,
    this.durationMinHours,
    this.durationMaxHours,
    this.physicalDemand,
    this.skillLevelRequired,
    this.fitnessLevel,
    this.elevationMin,
    this.elevationMax,
    this.elevationUnit,
    this.bestSeason,
    this.mealsIncluded,
    this.accommodationType,
    this.videoUrl,
    this.hasGroupChat,
    this.emergencySupportPhone,
    this.isFeatured,
    this.isPublic,
    this.averageRating,
    this.reviewCount,
  }) : tripId = tripId ?? const Uuid().v4(),
       status = status ?? 'planned';

  TripEntity toEntity() {
    return TripEntity(
      tripId: tripId,
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
      budget: budget,
      difficultyLevel: difficultyLevel,
      activities: activities,
      distanceMin: distanceMin,
      distanceMax: distanceMax,
      distanceUnit: distanceUnit,
      durationMinHours: durationMinHours,
      durationMaxHours: durationMaxHours,
      physicalDemand: physicalDemand,
      skillLevelRequired: skillLevelRequired,
      fitnessLevel: fitnessLevel,
      elevationMin: elevationMin,
      elevationMax: elevationMax,
      elevationUnit: elevationUnit,
      bestSeason: bestSeason,
      mealsIncluded: mealsIncluded,
      accommodationType: accommodationType,
      videoUrl: videoUrl,
      hasGroupChat: hasGroupChat,
      emergencySupportPhone: emergencySupportPhone,
      isFeatured: isFeatured,
      isPublic: isPublic,
      averageRating: averageRating,
      reviewCount: reviewCount,
    );
  }

  factory TripHiveModel.fromEntity(TripEntity entity) {
    return TripHiveModel(
      tripId: entity.tripId ?? const Uuid().v4(),
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
      budget: entity.budget,
      difficultyLevel: entity.difficultyLevel,
      activities: entity.activities,
      distanceMin: entity.distanceMin,
      distanceMax: entity.distanceMax,
      distanceUnit: entity.distanceUnit,
      durationMinHours: entity.durationMinHours,
      durationMaxHours: entity.durationMaxHours,
      physicalDemand: entity.physicalDemand,
      skillLevelRequired: entity.skillLevelRequired,
      fitnessLevel: entity.fitnessLevel,
      elevationMin: entity.elevationMin,
      elevationMax: entity.elevationMax,
      elevationUnit: entity.elevationUnit,
      bestSeason: entity.bestSeason,
      mealsIncluded: entity.mealsIncluded,
      accommodationType: entity.accommodationType,
      videoUrl: entity.videoUrl,
      hasGroupChat: entity.hasGroupChat,
      emergencySupportPhone: entity.emergencySupportPhone,
      isFeatured: entity.isFeatured,
      isPublic: entity.isPublic,
      averageRating: entity.averageRating,
      reviewCount: entity.reviewCount,
    );
  }

  static List<TripEntity> toEntityList(List<TripHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

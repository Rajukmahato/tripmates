import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/trip/data/repositories/trip_repository.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

class CreateTripParams extends Equatable {
  final String tripName;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final TripStatus status;
  final String? description;
  final String? category;
  final String? media;
  final List<String>? destinationIds;
  final String userId;

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
  final bool? guideIncluded;
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
  final double? budget;
  final List<String>? activities;
  final String? difficultyLevel;
  final String? travelType;
  final int? groupSizeMin;
  final int? groupSizeMax;

  const CreateTripParams({
    required this.tripName,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.description,
    this.category,
    this.media,
    this.destinationIds,
    required this.userId,
    this.distanceMin,
    this.distanceMax,
    this.distanceUnit,
    this.durationMinHours,
    this.durationMaxHours,
    this.physicalDemand,
    this.skillLevelRequired,
    this.fitnessLevel,
    this.maxMembers,
    this.favoriteCount,
    this.bestSeason,
    this.bestMonths,
    this.elevationMin,
    this.elevationMax,
    this.elevationUnit,
    this.inclusions,
    this.exclusions,
    this.guideIncluded,
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
    this.budget,
    this.activities,
    this.difficultyLevel,
    this.travelType,
    this.groupSizeMin,
    this.groupSizeMax,
  });

  @override
  List<Object?> get props => [
    tripName,
    destination,
    startDate,
    endDate,
    status,
    description,
    category,
    media,
    destinationIds,
    userId,
    distanceMin,
    distanceMax,
    distanceUnit,
    durationMinHours,
    durationMaxHours,
    physicalDemand,
    skillLevelRequired,
    fitnessLevel,
    maxMembers,
    favoriteCount,
    bestSeason,
    bestMonths,
    elevationMin,
    elevationMax,
    elevationUnit,
    inclusions,
    exclusions,
    guideIncluded,
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
    budget,
    activities,
    difficultyLevel,
    travelType,
    groupSizeMin,
    groupSizeMax,
  ];
}

final createTripUsecaseProvider = Provider<CreateTripUsecase>((ref) {
  final tripRepository = ref.read(tripRepositoryProvider);
  return CreateTripUsecase(tripRepository: tripRepository);
});

class CreateTripUsecase implements UsecaseWithParms<bool, CreateTripParams> {
  final ITripRepository _tripRepository;

  CreateTripUsecase({required ITripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  Future<Either<Failure, bool>> call(CreateTripParams params) {
    print('🟡 [CreateTripUsecase] Called with trip: ${params.tripName}');
    final tripEntity = TripEntity(
      tripName: params.tripName,
      destination: params.destination,
      startDate: params.startDate,
      endDate: params.endDate,
      status: params.status,
      description: params.description,
      category: params.category,
      media: params.media,
      destinationIds: params.destinationIds,
      createdBy: params.userId,
      createdAt: DateTime.now(),
      // Web parity fields
      budget: params.budget,
      distanceMin: params.distanceMin,
      distanceMax: params.distanceMax,
      distanceUnit: params.distanceUnit,
      durationMinHours: params.durationMinHours,
      durationMaxHours: params.durationMaxHours,
      difficultyLevel: params.difficultyLevel,
      fitnessLevel: params.fitnessLevel,
      physicalDemand: params.physicalDemand,
      skillLevelRequired: params.skillLevelRequired,
      bestSeason: params.bestSeason,
      bestMonths: params.bestMonths,
      elevationMin: params.elevationMin,
      elevationMax: params.elevationMax,
      elevationUnit: params.elevationUnit,
      inclusions: params.inclusions,
      exclusions: params.exclusions,
      mealsIncluded: params.mealsIncluded,
      accommodationType: params.accommodationType,
      highlights: params.highlights,
      keyAttractions: params.keyAttractions,
      gallery: params.gallery,
      videoUrl: params.videoUrl,
      hasGroupChat: params.hasGroupChat,
      emergencySupportPhone: params.emergencySupportPhone,
      isFeatured: params.isFeatured,
      isPublic: params.isPublic,
      activities: params.activities,
      maxMembers: params.maxMembers,
      favoriteCount: params.favoriteCount,
      travelType: params.travelType,
      groupSizeMin: params.groupSizeMin,
      groupSizeMax: params.groupSizeMax,
    );

    print('🟡 [CreateTripUsecase] Calling repository.createTrip');
    return _tripRepository.createTrip(tripEntity);
  }
}

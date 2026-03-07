import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/entities/trip_member_entity.dart';
import 'package:tripmates/features/trip/domain/entities/itinerary_item_entity.dart';
import 'package:tripmates/features/trip/domain/entities/checklist_item_entity.dart';
import '../../../../core/api/api_endpoints.dart';

String? _resolveMedia(String? media) {
  if (media == null || media.isEmpty) return null;
  if (media.startsWith('http')) return media;
  final cleaned = media.startsWith('/') ? media.substring(1) : media;
  return '${ApiEndpoints.baseOrigin}/$cleaned';
}

int? _parseIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

class TripApiModel {
  final String? id;
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
  final String status;
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

  TripApiModel({
    this.id,
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
    this.status = 'planned',
    this.destinationIds,
    this.averageRating,
    this.members,
    this.itinerary,
    this.checklist,
    this.notes,
    this.reviewCount,
    this.groupChatId,
    this.createdAt,
    this.updatedAt,
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
      if (budget != null) 'budget': budget,
      if (travelType != null) 'travelType': travelType,
      if (groupSizeMin != null) 'groupSizeMin': groupSizeMin,
      if (groupSizeMax != null) 'groupSizeMax': groupSizeMax,
      if (activities != null) 'activities': activities,
      if (difficultyLevel != null) 'difficultyLevel': difficultyLevel,
      if (distanceMin != null) 'distanceMin': distanceMin,
      if (distanceMax != null) 'distanceMax': distanceMax,
      if (distanceUnit != null) 'distanceUnit': distanceUnit,
      if (durationMinHours != null) 'durationMinHours': durationMinHours,
      if (durationMaxHours != null) 'durationMaxHours': durationMaxHours,
      if (physicalDemand != null) 'physicalDemand': physicalDemand,
      if (skillLevelRequired != null) 'skillLevelRequired': skillLevelRequired,
      if (fitnessLevel != null) 'fitnessLevel': fitnessLevel,
      if (maxMembers != null) 'maxMembers': maxMembers,
      if (currentMembers != null) 'currentMembers': currentMembers,
      if (favoriteCount != null) 'favoriteCount': favoriteCount,
      if (bestSeason != null) 'bestSeason': bestSeason,
      if (bestMonths != null) 'bestMonths': bestMonths,
      if (elevationMin != null) 'elevationMin': elevationMin,
      if (elevationMax != null) 'elevationMax': elevationMax,
      if (elevationUnit != null) 'elevationUnit': elevationUnit,
      if (inclusions != null) 'inclusions': inclusions,
      if (exclusions != null) 'exclusions': exclusions,
      if (mealsIncluded != null) 'mealsIncluded': mealsIncluded,
      if (accommodationType != null) 'accommodationType': accommodationType,
      if (highlights != null) 'highlights': highlights,
      if (keyAttractions != null) 'keyAttractions': keyAttractions,
      if (gallery != null) 'gallery': gallery,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (hasGroupChat != null) 'hasGroupChat': hasGroupChat,
      if (emergencySupportPhone != null)
        'emergencySupportPhone': emergencySupportPhone,
      if (isFeatured != null) 'isFeatured': isFeatured,
      if (isPublic != null) 'isPublic': isPublic,
    };
  }

  factory TripApiModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value['_id'] as String?;
      return value as String?;
    }

    // Extract creator details from object or string id
    final creatorRaw = json['creator'];
    final creator = creatorRaw is Map<String, dynamic> ? creatorRaw : null;
    final creatorId = extractId(creatorRaw);
    final creatorName = creator?['fullName'] as String?;
    final creatorAvatar = creator?['profileImagePath'] as String?;

    // Backend uses single 'groupSize', map to groupSizeMax
    final groupSize = _parseIntValue(json['groupSize']);

    // Backend uses 'image' field instead of 'media'
    final imageUrl = json['image'] as String? ?? json['media'] as String?;

    // Parse members array
    List<TripMemberEntity>? members;
    if (json['members'] is List) {
      members = (json['members'] as List).map((m) {
        final memberMap = m as Map<String, dynamic>;
        return TripMemberEntity(
          userId: memberMap['_id'] as String? ?? '',
          fullName: memberMap['fullName'] as String? ?? 'Unknown',
          email: memberMap['email'] as String? ?? '',
          profilePicture: _resolveMedia(
            memberMap['profileImagePath'] as String?,
          ),
          role: memberMap['role'] as String?,
        );
      }).toList();
    }

    // Parse itinerary
    List<ItineraryItemEntity>? itinerary;
    if (json['itinerary'] is List) {
      itinerary = (json['itinerary'] as List).map((item) {
        final itemMap = item as Map<String, dynamic>;
        return ItineraryItemEntity(
          id: itemMap['_id'] as String? ?? itemMap['id'] as String? ?? '',
          day: itemMap['day'] as int? ?? 1,
          date: DateTime.parse(itemMap['date'] as String),
          title: itemMap['title'] as String,
          description: itemMap['description'] as String?,
          location: itemMap['location'] as String?,
          activities: itemMap['activities'] != null
              ? List<String>.from(itemMap['activities'] as List)
              : null,
          elevation: itemMap['elevation'] != null
              ? (itemMap['elevation'] as num).toDouble()
              : null,
          startTime: itemMap['startTime'] != null
              ? DateTime.parse(itemMap['startTime'] as String)
              : null,
          endTime: itemMap['endTime'] != null
              ? DateTime.parse(itemMap['endTime'] as String)
              : null,
          notes: itemMap['notes'] as String?,
          isCompleted: itemMap['isCompleted'] as bool? ?? false,
        );
      }).toList();
    }

    // Parse checklist (travelChecklist)
    List<ChecklistItemEntity>? checklist;
    if (json['travelChecklist'] is List) {
      checklist = (json['travelChecklist'] as List).map((item) {
        if (item is String) {
          // Legacy format: just a string
          return ChecklistItemEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            category: ChecklistCategory.preparation, // Default category
            title: item,
          );
        } else if (item is Map<String, dynamic>) {
          // Parse category from string
          ChecklistCategory category = ChecklistCategory.preparation;
          if (item['category'] != null) {
            try {
              category = ChecklistCategory.values.firstWhere(
                (e) => e.name == item['category'],
                orElse: () => ChecklistCategory.preparation,
              );
            } catch (e) {
              category = ChecklistCategory.preparation;
            }
          }

          // Parse priority from string
          ChecklistPriority? priority;
          if (item['priority'] != null) {
            try {
              priority = ChecklistPriority.values.firstWhere(
                (e) => e.name == item['priority'],
              );
            } catch (e) {
              priority = null;
            }
          }

          return ChecklistItemEntity(
            id: item['_id'] as String? ?? item['id'] as String? ?? '',
            category: category,
            title: item['title'] as String,
            isCompleted: item['isCompleted'] as bool? ?? false,
            priority: priority,
            completedAt: item['completedAt'] != null
                ? DateTime.tryParse(item['completedAt'] as String)
                : null,
            completedBy: item['completedBy'] as String?,
            createdAt: item['createdAt'] != null
                ? DateTime.tryParse(item['createdAt'] as String)
                : null,
          );
        }
        return ChecklistItemEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: ChecklistCategory.preparation,
          title: 'Unknown',
        );
      }).toList();
    }

    return TripApiModel(
      id: json['tripId'] as String? ?? json['_id'] as String?,
      createdBy: creatorId ?? extractId(json['createdBy']),
      createdByName: creatorName ?? json['createdByName'] as String?,
      createdByAvatar: creatorAvatar ?? json['createdByAvatar'] as String?,
      tripName: json['tripName'] as String? ?? json['destination'] as String,
      description: json['description'] as String?,
      destination: json['destination'] as String,
      category: extractId(json['category']),
      budget: (json['budget'] as num?)?.toDouble(),
      travelType: json['travelType'] as String?,
      groupSizeMin: _parseIntValue(json['groupSizeMin']),
      groupSizeMax: groupSize ?? _parseIntValue(json['groupSizeMax']),
      activities: (json['activities'] as List?)?.cast<String>(),
      difficultyLevel: json['difficultyLevel'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      media: _resolveMedia(imageUrl),
      mediaType: json['mediaType'] as String?,
      status: json['status'] as String? ?? 'planned',
      destinationIds: (json['destinationIds'] as List?)?.cast<String>(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      groupChatId: json['groupChatId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      members: members,
      itinerary: itinerary,
      checklist: checklist,
      notes: json['notes'] as String?,
      distanceMin: (json['distanceMin'] as num?)?.toDouble(),
      distanceMax: (json['distanceMax'] as num?)?.toDouble(),
      distanceUnit: json['distanceUnit'] as String?,
      durationMinHours: _parseIntValue(json['durationMinHours']),
      durationMaxHours: _parseIntValue(json['durationMaxHours']),
      physicalDemand: json['physicalDemand'] as String?,
      skillLevelRequired: json['skillLevelRequired'] as String?,
      fitnessLevel: json['fitnessLevel'] as String?,
      maxMembers: _parseIntValue(json['maxMembers']),
      currentMembers: _parseIntValue(json['currentMembers']),
      favoriteCount: _parseIntValue(json['favoriteCount']),
      bestSeason: json['bestSeason'] as String?,
      bestMonths: (json['bestMonths'] as List?)?.cast<String>(),
      elevationMin: _parseIntValue(json['elevationMin']),
      elevationMax: _parseIntValue(json['elevationMax']),
      elevationUnit: json['elevationUnit'] as String?,
      inclusions: (json['inclusions'] as List?)?.cast<String>(),
      exclusions: (json['exclusions'] as List?)?.cast<String>(),
      mealsIncluded: json['mealsIncluded'] as String?,
      accommodationType: json['accommodationType'] as String?,
      highlights: (json['highlights'] as List?)?.cast<String>(),
      keyAttractions: (json['keyAttractions'] as List?)?.cast<String>(),
      gallery: (json['gallery'] as List?)?.cast<String>(),
      videoUrl: json['videoUrl'] as String?,
      hasGroupChat: json['hasGroupChat'] as bool?,
      emergencySupportPhone: json['emergencySupportPhone'] as String?,
      isFeatured: json['isFeatured'] as bool?,
      isPublic: json['isPublic'] as bool?,
    );
  }

  TripEntity toEntity() {
    return TripEntity(
      tripId: id,
      createdBy: createdBy,
      createdByName: createdByName,
      createdByAvatar: _resolveMedia(createdByAvatar),
      tripName: tripName,
      description: description,
      destination: destination,
      category: category,
      budget: budget,
      travelType: travelType,
      groupSizeMin: groupSizeMin,
      groupSizeMax: groupSizeMax,
      activities: activities,
      difficultyLevel: difficultyLevel,
      startDate: startDate,
      endDate: endDate,
      media: media,
      mediaType: mediaType,
      status: status == 'planned' || status == 'open'
          ? TripStatus.planned
          : status == 'ongoing'
          ? TripStatus.ongoing
          : TripStatus.completed,
      destinationIds: destinationIds,
      averageRating: averageRating,
      reviewCount: reviewCount,
      groupChatId: groupChatId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      members: members,
      itinerary: itinerary,
      checklist: checklist,
      notes: notes,
      distanceMin: distanceMin,
      distanceMax: distanceMax,
      distanceUnit: distanceUnit,
      durationMinHours: durationMinHours,
      durationMaxHours: durationMaxHours,
      physicalDemand: physicalDemand,
      skillLevelRequired: skillLevelRequired,
      fitnessLevel: fitnessLevel,
      maxMembers: maxMembers,
      currentMembers: currentMembers,
      favoriteCount: favoriteCount,
      bestSeason: bestSeason,
      bestMonths: bestMonths,
      elevationMin: elevationMin,
      elevationMax: elevationMax,
      elevationUnit: elevationUnit,
      inclusions: inclusions,
      exclusions: exclusions,
      mealsIncluded: mealsIncluded,
      accommodationType: accommodationType,
      highlights: highlights,
      keyAttractions: keyAttractions,
      gallery: gallery,
      videoUrl: videoUrl,
      hasGroupChat: hasGroupChat,
      emergencySupportPhone: emergencySupportPhone,
      isFeatured: isFeatured,
      isPublic: isPublic,
    );
  }

  factory TripApiModel.fromEntity(TripEntity entity) {
    return TripApiModel(
      id: entity.tripId,
      createdBy: entity.createdBy,
      createdByName: entity.createdByName,
      createdByAvatar: entity.createdByAvatar,
      tripName: entity.tripName,
      description: entity.description,
      destination: entity.destination,
      category: entity.category,
      budget: entity.budget,
      travelType: entity.travelType,
      groupSizeMin: entity.groupSizeMin,
      groupSizeMax: entity.groupSizeMax,
      activities: entity.activities,
      difficultyLevel: entity.difficultyLevel,
      startDate: entity.startDate,
      endDate: entity.endDate,
      media: entity.media,
      mediaType: entity.mediaType,
      status: entity.status.toString().split('.').last,
      destinationIds: entity.destinationIds,
      averageRating: entity.averageRating,
      reviewCount: entity.reviewCount,
      groupChatId: entity.groupChatId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      distanceMin: entity.distanceMin,
      distanceMax: entity.distanceMax,
      distanceUnit: entity.distanceUnit,
      durationMinHours: entity.durationMinHours,
      durationMaxHours: entity.durationMaxHours,
      physicalDemand: entity.physicalDemand,
      skillLevelRequired: entity.skillLevelRequired,
      fitnessLevel: entity.fitnessLevel,
      maxMembers: entity.maxMembers,
      currentMembers: entity.currentMembers,
      favoriteCount: entity.favoriteCount,
      bestSeason: entity.bestSeason,
      bestMonths: entity.bestMonths,
      elevationMin: entity.elevationMin,
      elevationMax: entity.elevationMax,
      elevationUnit: entity.elevationUnit,
      inclusions: entity.inclusions,
      exclusions: entity.exclusions,
      mealsIncluded: entity.mealsIncluded,
      accommodationType: entity.accommodationType,
      highlights: entity.highlights,
      keyAttractions: entity.keyAttractions,
      gallery: entity.gallery,
      videoUrl: entity.videoUrl,
      hasGroupChat: entity.hasGroupChat,
      emergencySupportPhone: entity.emergencySupportPhone,
      isFeatured: entity.isFeatured,
      isPublic: entity.isPublic,
    );
  }

  static List<TripEntity> toEntityList(List<TripApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

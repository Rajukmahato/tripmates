import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/features/destination/domain/entities/destination_entity.dart';
import 'package:uuid/uuid.dart';

part 'destination_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.destinationTypeId)
class DestinationHiveModel extends HiveObject {
  @HiveField(0)
  final String? destinationId;

  @HiveField(1)
  final String? tripId;

  @HiveField(2)
  final String? createdBy;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final String destinationName;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String location;

  @HiveField(7)
  final String? media;

  @HiveField(8)
  final String? mediaType;

  @HiveField(9)
  final DateTime? visitDate;

  @HiveField(10)
  final bool isVisited;

  @HiveField(11)
  final double? budget;

  @HiveField(12)
  final String? notes;

  DestinationHiveModel({
    String? destinationId,
    this.tripId,
    this.createdBy,
    this.category,
    required this.destinationName,
    this.description,
    required this.location,
    this.media,
    this.mediaType,
    this.visitDate,
    bool? isVisited,
    this.budget,
    this.notes,
  }) : destinationId = destinationId ?? const Uuid().v4(),
       isVisited = isVisited ?? false;

  DestinationEntity toEntity() {
    return DestinationEntity(
      destinationId: destinationId,
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
    );
  }

  factory DestinationHiveModel.fromEntity(DestinationEntity entity) {
    return DestinationHiveModel(
      destinationId: entity.destinationId,
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
    );
  }

  static List<DestinationEntity> toEntityList(
    List<DestinationHiveModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}

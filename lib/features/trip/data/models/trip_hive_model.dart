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
    );
  }

  factory TripHiveModel.fromEntity(TripEntity entity) {
    return TripHiveModel(
      tripId: entity.tripId,
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
    );
  }

  static List<TripEntity> toEntityList(List<TripHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripHiveModelAdapter extends TypeAdapter<TripHiveModel> {
  @override
  final int typeId = 1;

  @override
  TripHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripHiveModel(
      tripId: fields[0] as String?,
      createdBy: fields[1] as String?,
      tripName: fields[2] as String,
      description: fields[3] as String?,
      destination: fields[4] as String,
      category: fields[5] as String?,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime,
      media: fields[8] as String?,
      mediaType: fields[9] as String?,
      status: fields[10] as String?,
      destinationIds: (fields[11] as List?)?.cast<String>(),
      budget: fields[12] as double?,
      difficultyLevel: fields[13] as String?,
      activities: (fields[14] as List?)?.cast<String>(),
      distanceMin: fields[15] as double?,
      distanceMax: fields[16] as double?,
      distanceUnit: fields[17] as String?,
      durationMinHours: fields[18] as int?,
      durationMaxHours: fields[19] as int?,
      physicalDemand: fields[20] as String?,
      skillLevelRequired: fields[21] as String?,
      fitnessLevel: fields[22] as String?,
      elevationMin: fields[23] as int?,
      elevationMax: fields[24] as int?,
      elevationUnit: fields[25] as String?,
      bestSeason: fields[26] as String?,
      mealsIncluded: fields[27] as String?,
      accommodationType: fields[28] as String?,
      videoUrl: fields[29] as String?,
      hasGroupChat: fields[30] as bool?,
      emergencySupportPhone: fields[31] as String?,
      isFeatured: fields[32] as bool?,
      isPublic: fields[33] as bool?,
      averageRating: fields[34] as double?,
      reviewCount: fields[35] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TripHiveModel obj) {
    writer
      ..writeByte(36)
      ..writeByte(0)
      ..write(obj.tripId)
      ..writeByte(1)
      ..write(obj.createdBy)
      ..writeByte(2)
      ..write(obj.tripName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.destination)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.media)
      ..writeByte(9)
      ..write(obj.mediaType)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.destinationIds)
      ..writeByte(12)
      ..write(obj.budget)
      ..writeByte(13)
      ..write(obj.difficultyLevel)
      ..writeByte(14)
      ..write(obj.activities)
      ..writeByte(15)
      ..write(obj.distanceMin)
      ..writeByte(16)
      ..write(obj.distanceMax)
      ..writeByte(17)
      ..write(obj.distanceUnit)
      ..writeByte(18)
      ..write(obj.durationMinHours)
      ..writeByte(19)
      ..write(obj.durationMaxHours)
      ..writeByte(20)
      ..write(obj.physicalDemand)
      ..writeByte(21)
      ..write(obj.skillLevelRequired)
      ..writeByte(22)
      ..write(obj.fitnessLevel)
      ..writeByte(23)
      ..write(obj.elevationMin)
      ..writeByte(24)
      ..write(obj.elevationMax)
      ..writeByte(25)
      ..write(obj.elevationUnit)
      ..writeByte(26)
      ..write(obj.bestSeason)
      ..writeByte(27)
      ..write(obj.mealsIncluded)
      ..writeByte(28)
      ..write(obj.accommodationType)
      ..writeByte(29)
      ..write(obj.videoUrl)
      ..writeByte(30)
      ..write(obj.hasGroupChat)
      ..writeByte(31)
      ..write(obj.emergencySupportPhone)
      ..writeByte(32)
      ..write(obj.isFeatured)
      ..writeByte(33)
      ..write(obj.isPublic)
      ..writeByte(34)
      ..write(obj.averageRating)
      ..writeByte(35)
      ..write(obj.reviewCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

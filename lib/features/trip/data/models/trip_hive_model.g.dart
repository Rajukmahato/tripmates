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
    );
  }

  @override
  void write(BinaryWriter writer, TripHiveModel obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.destinationIds);
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

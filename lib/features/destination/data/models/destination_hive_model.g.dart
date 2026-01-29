// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DestinationHiveModelAdapter extends TypeAdapter<DestinationHiveModel> {
  @override
  final int typeId = 2;

  @override
  DestinationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DestinationHiveModel(
      destinationId: fields[0] as String?,
      tripId: fields[1] as String?,
      createdBy: fields[2] as String?,
      category: fields[3] as String?,
      destinationName: fields[4] as String,
      description: fields[5] as String?,
      location: fields[6] as String,
      media: fields[7] as String?,
      mediaType: fields[8] as String?,
      visitDate: fields[9] as DateTime?,
      isVisited: fields[10] as bool?,
      budget: fields[11] as double?,
      notes: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DestinationHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.destinationId)
      ..writeByte(1)
      ..write(obj.tripId)
      ..writeByte(2)
      ..write(obj.createdBy)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.destinationName)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.media)
      ..writeByte(8)
      ..write(obj.mediaType)
      ..writeByte(9)
      ..write(obj.visitDate)
      ..writeByte(10)
      ..write(obj.isVisited)
      ..writeByte(11)
      ..write(obj.budget)
      ..writeByte(12)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DestinationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

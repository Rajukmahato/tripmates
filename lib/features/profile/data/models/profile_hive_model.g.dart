// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileHiveModelAdapter extends TypeAdapter<ProfileHiveModel> {
  @override
  final int typeId = 4;

  @override
  ProfileHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileHiveModel(
      userId: fields[0] as String?,
      fullName: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String?,
      profilePicture: fields[4] as String?,
      bio: fields[5] as String?,
      location: fields[6] as String?,
      totalTrips: fields[7] as int,
      completedTrips: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.profilePicture)
      ..writeByte(5)
      ..write(obj.bio)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.totalTrips)
      ..writeByte(8)
      ..write(obj.completedTrips);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

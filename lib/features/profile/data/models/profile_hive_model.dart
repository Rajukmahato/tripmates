import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.profileTypeId)
class ProfileHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? profilePicture;

  @HiveField(5)
  final String? bio;

  @HiveField(6)
  final String? location;

  @HiveField(7)
  final int totalTrips;

  @HiveField(8)
  final int completedTrips;

  ProfileHiveModel({
    this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.profilePicture,
    this.bio,
    this.location,
    this.totalTrips = 0,
    this.completedTrips = 0,
  });

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phone: phone,
      profilePicture: profilePicture,
      bio: bio,
      location: location,
      totalTrips: totalTrips,
      completedTrips: completedTrips,
    );
  }

  factory ProfileHiveModel.fromEntity(ProfileEntity entity) {
    return ProfileHiveModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      profilePicture: entity.profilePicture,
      bio: entity.bio,
      location: entity.location,
      totalTrips: entity.totalTrips,
      completedTrips: entity.completedTrips,
    );
  }
}

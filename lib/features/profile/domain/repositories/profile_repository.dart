import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile(String userId);
  Future<Either<Failure, bool>> updateProfile(ProfileEntity profile);
  Future<Either<Failure, bool>> deleteAccount(String userId);
  Future<Either<Failure, String>> uploadProfilePicture(
    File photo,
    String userId,
  );
}

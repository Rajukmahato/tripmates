import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/profile/data/repositories/profile_repository.dart';
import 'package:tripmates/features/profile/domain/repositories/profile_repository.dart';

class UploadProfilePictureParams extends Equatable {
  final File photo;

  final String? userId;

  const UploadProfilePictureParams({required this.photo, this.userId});

  @override
  List<Object?> get props => [photo];
}

final uploadProfilePictureUsecaseProvider =
    Provider<UploadProfilePictureUsecase>((ref) {
      final repository = ref.read(profileRepositoryProvider);
      return UploadProfilePictureUsecase(repository: repository);
    });

class UploadProfilePictureUsecase
    implements UsecaseWithParms<String, UploadProfilePictureParams> {
  final IProfileRepository _repository;

  UploadProfilePictureUsecase({required IProfileRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, String>> call(UploadProfilePictureParams params) {
    if (params.userId == null || params.userId!.isEmpty) {
      return Future.value(Left(ApiFailure(message: 'User id is required')));
    }
    return _repository.uploadProfilePicture(params.photo, params.userId!);
  }
}

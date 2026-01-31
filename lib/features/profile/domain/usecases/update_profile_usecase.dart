import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/profile/data/repositories/profile_repository.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import 'package:tripmates/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileParams extends Equatable {
  final ProfileEntity profile;

  const UpdateProfileParams({required this.profile});

  @override
  List<Object?> get props => [profile];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return UpdateProfileUsecase(repository: repository);
});

class UpdateProfileUsecase
    implements UsecaseWithParms<bool, UpdateProfileParams> {
  final IProfileRepository _repository;

  UpdateProfileUsecase({required IProfileRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(UpdateProfileParams params) {
    return _repository.updateProfile(params.profile);
  }
}

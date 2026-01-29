import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/profile/data/repositories/profile_repository.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import 'package:tripmates/features/profile/domain/repositories/profile_repository.dart';

class GetProfileParams extends Equatable {
  final String userId;

  const GetProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getProfileUsecaseProvider = Provider<GetProfileUsecase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return GetProfileUsecase(repository: repository);
});

class GetProfileUsecase
    implements UsecaseWithParms<ProfileEntity, GetProfileParams> {
  final IProfileRepository _repository;

  GetProfileUsecase({required IProfileRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProfileEntity>> call(GetProfileParams params) {
    return _repository.getProfile(params.userId);
  }
}

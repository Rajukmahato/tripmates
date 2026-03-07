import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/admin/domain/entities/admin_user_entity.dart';
import 'package:tripmates/features/admin/domain/repositories/admin_repository.dart';
import 'package:tripmates/features/admin/domain/usecases/get_overview_stats_usecase.dart';

/// Use case to get all users for admin
class GetAllUsersUseCase implements UsecaseWithoutParms<List<AdminUserEntity>> {
  final AdminRepository repository;

  GetAllUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<AdminUserEntity>>> call() {
    return repository.getAllUsers();
  }
}

/// Provider
final getAllUsersUseCaseProvider = Provider<GetAllUsersUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetAllUsersUseCase(repository);
});

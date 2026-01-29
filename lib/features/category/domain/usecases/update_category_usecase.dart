import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/category/data/repositories/category_repository.dart';
import 'package:tripmates/features/category/domain/entities/category_entity.dart';
import 'package:tripmates/features/category/domain/repositories/category_repository.dart';

class UpdateCategoryParams extends Equatable {
  final String categoryId;
  final String categoryName;
  final String? description;
  final String? icon;
  final TravelCategoryType type;

  const UpdateCategoryParams({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.icon,
    this.type = TravelCategoryType.custom,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    description,
    icon,
    type,
  ];
}

final updateCategoryUsecaseProvider = Provider<UpdateCategoryUsecase>((ref) {
  final categoryRepository = ref.read(categoryRepositoryProvider);
  return UpdateCategoryUsecase(categoryRepository: categoryRepository);
});

class UpdateCategoryUsecase
    implements UsecaseWithParms<bool, UpdateCategoryParams> {
  final ICategoryRepository _categoryRepository;

  UpdateCategoryUsecase({required ICategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateCategoryParams params) {
    final categoryEntity = CategoryEntity(
      categoryId: params.categoryId,
      categoryName: params.categoryName,
      description: params.description,
      icon: params.icon,
      type: params.type,
    );

    return _categoryRepository.updateCategory(categoryEntity);
  }
}

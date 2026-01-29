import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/category/data/repositories/category_repository.dart';
import 'package:tripmates/features/category/domain/entities/category_entity.dart';
import 'package:tripmates/features/category/domain/repositories/category_repository.dart';

class CreateCategoryParams extends Equatable {
  final String categoryName;
  final String? description;
  final String? icon;
  final TravelCategoryType type;

  const CreateCategoryParams({
    required this.categoryName,
    this.description,
    this.icon,
    this.type = TravelCategoryType.custom,
  });

  @override
  List<Object?> get props => [categoryName, description, icon, type];
}

final createCategoryUsecaseProvider = Provider<CreateCategoryUsecase>((ref) {
  final categoryRepository = ref.read(categoryRepositoryProvider);
  return CreateCategoryUsecase(categoryRepository: categoryRepository);
});

class CreateCategoryUsecase
    implements UsecaseWithParms<bool, CreateCategoryParams> {
  final ICategoryRepository _categoryRepository;

  CreateCategoryUsecase({required ICategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, bool>> call(CreateCategoryParams params) {
    final categoryEntity = CategoryEntity(
      categoryName: params.categoryName,
      description: params.description,
      icon: params.icon,
      type: params.type,
    );

    return _categoryRepository.createCategory(categoryEntity);
  }
}

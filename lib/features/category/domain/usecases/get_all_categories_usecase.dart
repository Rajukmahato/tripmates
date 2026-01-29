import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/category/data/repositories/category_repository.dart';
import 'package:tripmates/features/category/domain/entities/category_entity.dart';
import 'package:tripmates/features/category/domain/repositories/category_repository.dart';

final getAllCategoriesUsecaseProvider = Provider<GetAllCategoriesUsecase>((
  ref,
) {
  final categoryRepository = ref.read(categoryRepositoryProvider);
  return GetAllCategoriesUsecase(categoryRepository: categoryRepository);
});

class GetAllCategoriesUsecase
    implements UsecaseWithoutParms<List<CategoryEntity>> {
  final ICategoryRepository _categoryRepository;

  GetAllCategoriesUsecase({required ICategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() {
    return _categoryRepository.getAllCategories();
  }
}

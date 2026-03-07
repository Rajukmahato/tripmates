import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/category/data/datasources/category_datasource.dart';
import 'package:tripmates/features/category/data/datasources/local/category_local_datasource.dart';
import 'package:tripmates/features/category/data/datasources/remote/category_remote_datasource.dart';
import 'package:tripmates/features/category/data/models/category_api_model.dart';
import 'package:tripmates/features/category/data/models/category_hive_model.dart';
import 'package:tripmates/features/category/domain/entities/category_entity.dart';
import 'package:tripmates/features/category/domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  final categoryLocalDatasource = ref.read(categoryLocalDatasourceProvider);
  final categoryRemoteDatasource = ref.read(categoryRemoteDatasourceProvider);
  return CategoryRepository(
    categoryLocalDatasource: categoryLocalDatasource,
    categoryRemoteDatasource: categoryRemoteDatasource,
  );
});

class CategoryRepository implements ICategoryRepository {
  final ICategoryDataSource _categoryLocalDataSource;
  final ICategoryRemoteDataSource _categoryRemoteDataSource;

  CategoryRepository({
    required ICategoryDataSource categoryLocalDatasource,
    required ICategoryRemoteDataSource categoryRemoteDatasource,
  }) : _categoryLocalDataSource = categoryLocalDatasource,
       _categoryRemoteDataSource = categoryRemoteDatasource;

  @override
  Future<Either<Failure, bool>> createCategory(CategoryEntity category) async {
    try {
      final categoryModel = CategoryHiveModel.fromEntity(category);
      final result = await _categoryLocalDataSource.createCategory(
        categoryModel,
      );
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to create category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(String categoryId) async {
    try {
      final result = await _categoryLocalDataSource.deleteCategory(categoryId);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to delete category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      final models = await _categoryRemoteDataSource.getAllCategories();
      final entities = CategoryApiModel.toEntityList(models);

      // Cache categories locally for offline access
      try {
        for (final entity in entities) {
          await _categoryLocalDataSource.createCategory(
            CategoryHiveModel.fromEntity(entity),
          );
        }
      } catch (_) {
        // Silently fail on cache update, don't affect the main flow
      }

      return Right(entities);
    } on ServerException catch (e) {
      // Try to load from local cache if remote fails
      try {
        final localModels = await _categoryLocalDataSource.getAllCategories();
        if (localModels.isNotEmpty) {
          final entities = localModels.map((m) => m.toEntity()).toList();
          return Right(entities);
        }
      } catch (_) {
        // Local cache also failed
      }
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      // Try to load from local cache for any other error
      try {
        final localModels = await _categoryLocalDataSource.getAllCategories();
        if (localModels.isNotEmpty) {
          final entities = localModels.map((m) => m.toEntity()).toList();
          return Right(entities);
        }
      } catch (_) {
        // Local cache also failed
      }
      return Left(
        ApiFailure(message: 'Failed to load categories: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(
    String categoryId,
  ) async {
    try {
      final model = await _categoryLocalDataSource.getCategoryById(categoryId);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: 'Category not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCategory(CategoryEntity category) async {
    try {
      final categoryModel = CategoryHiveModel.fromEntity(category);
      final result = await _categoryLocalDataSource.updateCategory(
        categoryModel,
      );
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to update category"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}

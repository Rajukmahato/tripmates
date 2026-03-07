import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/features/category/data/datasources/category_datasource.dart';
import 'package:tripmates/features/category/data/models/category_api_model.dart';
import 'package:tripmates/features/category/domain/entities/category_entity.dart';

final categoryRemoteDatasourceProvider = Provider<ICategoryRemoteDataSource>((
  ref,
) {
  return CategoryRemoteDatasource();
});

class CategoryRemoteDatasource implements ICategoryRemoteDataSource {
  CategoryRemoteDatasource();

  @override
  Future<List<CategoryApiModel>> getAllCategories() async {
    try {
      // Categories are predefined and don't require a backend API call
      // The backend doesn't have a /api/categories endpoint as categories
      // are just string attributes of trips (e.g., "Adventure", "Beach", etc.)

      // Return predefined categories as API models
      final predefinedCategories = CategoryEntity.predefinedCategories;

      if (predefinedCategories.isEmpty) {
        throw ServerException(message: 'No predefined categories available');
      }

      final categories = predefinedCategories
          .map((entity) => CategoryApiModel.fromEntity(entity))
          .toList();

      if (categories.isEmpty) {
        throw ServerException(
          message: 'Failed to convert categories to API models',
        );
      }

      return categories;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to load categories: ${e.toString()}',
      );
    }
  }
}

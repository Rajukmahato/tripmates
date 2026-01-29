import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/features/category/data/datasources/category_datasource.dart';
import 'package:tripmates/features/category/data/models/category_api_model.dart';

final categoryRemoteDatasourceProvider = Provider<ICategoryRemoteDataSource>((
  ref,
) {
  return CategoryRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class CategoryRemoteDatasource implements ICategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<CategoryApiModel>> getAllCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);
    final data = response.data['data'] as List;
    return data.map((json) => CategoryApiModel.fromJson(json)).toList();
  }
}

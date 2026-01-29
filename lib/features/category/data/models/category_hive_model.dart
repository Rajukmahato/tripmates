import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/features/category/domain/entities/category_entity.dart';
import 'package:uuid/uuid.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.categoryTypeId)
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  final String? categoryId;

  @HiveField(1)
  final String categoryName;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? icon;

  @HiveField(4)
  final String type;

  CategoryHiveModel({
    String? categoryId,
    required this.categoryName,
    this.description,
    this.icon,
    this.type = 'custom',
  }) : categoryId = categoryId ?? const Uuid().v4();

  CategoryEntity toEntity() {
    TravelCategoryType categoryType;
    switch (type) {
      case 'mountains':
        categoryType = TravelCategoryType.mountains;
        break;
      case 'cityTour':
        categoryType = TravelCategoryType.cityTour;
        break;
      case 'adventure':
        categoryType = TravelCategoryType.adventure;
        break;
      case 'religious':
        categoryType = TravelCategoryType.religious;
        break;
      case 'roadTrip':
        categoryType = TravelCategoryType.roadTrip;
        break;
      case 'nature':
        categoryType = TravelCategoryType.nature;
        break;
      case 'beach':
        categoryType = TravelCategoryType.beach;
        break;
      case 'cultural':
        categoryType = TravelCategoryType.cultural;
        break;
      default:
        categoryType = TravelCategoryType.custom;
    }

    return CategoryEntity(
      categoryId: categoryId,
      categoryName: categoryName,
      description: description,
      icon: icon,
      type: categoryType,
    );
  }

  factory CategoryHiveModel.fromEntity(CategoryEntity entity) {
    return CategoryHiveModel(
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      description: entity.description,
      icon: entity.icon,
      type: entity.type.toString().split('.').last,
    );
  }

  static List<CategoryEntity> toEntityList(List<CategoryHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

import 'package:tripmates/features/category/domain/entities/category_entity.dart';

class CategoryApiModel {
  final String? id;
  final String categoryName;
  final String? description;
  final String? icon;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryApiModel({
    this.id,
    required this.categoryName,
    this.description,
    this.icon,
    this.type = 'custom',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      'type': type,
    };
  }

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryApiModel(
      id: json['_id'] as String?,
      categoryName: json['categoryName'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      type: json['type'] as String? ?? 'custom',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

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
      categoryId: id,
      categoryName: categoryName,
      description: description,
      icon: icon,
      type: categoryType,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CategoryApiModel.fromEntity(CategoryEntity entity) {
    return CategoryApiModel(
      id: entity.categoryId,
      categoryName: entity.categoryName,
      description: entity.description,
      icon: entity.icon,
      type: entity.type.toString().split('.').last,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<CategoryEntity> toEntityList(List<CategoryApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

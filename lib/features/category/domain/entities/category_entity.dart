import 'package:equatable/equatable.dart';

// Predefined travel categories
enum TravelCategoryType {
  mountains,
  cityTour,
  adventure,
  religious,
  roadTrip,
  nature,
  beach,
  cultural,
  custom,
}

class CategoryEntity extends Equatable {
  final String? categoryId;
  final String categoryName;
  final String? description;
  final String? icon;
  final TravelCategoryType type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    this.categoryId,
    required this.categoryName,
    this.description,
    this.icon,
    this.type = TravelCategoryType.custom,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    description,
    icon,
    type,
    createdAt,
    updatedAt,
  ];

  // Predefined categories
  static const List<CategoryEntity> predefinedCategories = [
    CategoryEntity(
      categoryName: 'Mountains',
      description: 'Mountain treks and hill stations',
      icon: '⛰️',
      type: TravelCategoryType.mountains,
    ),
    CategoryEntity(
      categoryName: 'City Tour',
      description: 'Urban exploration and city sightseeing',
      icon: '🏙️',
      type: TravelCategoryType.cityTour,
    ),
    CategoryEntity(
      categoryName: 'Adventure',
      description: 'Thrilling adventures and extreme sports',
      icon: '🎢',
      type: TravelCategoryType.adventure,
    ),
    CategoryEntity(
      categoryName: 'Religious',
      description: 'Pilgrimage and spiritual journeys',
      icon: '🕉️',
      type: TravelCategoryType.religious,
    ),
    CategoryEntity(
      categoryName: 'Road Trip',
      description: 'Long drives and road adventures',
      icon: '🚗',
      type: TravelCategoryType.roadTrip,
    ),
    CategoryEntity(
      categoryName: 'Nature',
      description: 'Wildlife and natural wonders',
      icon: '🌿',
      type: TravelCategoryType.nature,
    ),
    CategoryEntity(
      categoryName: 'Beach',
      description: 'Coastal and beach destinations',
      icon: '🏖️',
      type: TravelCategoryType.beach,
    ),
    CategoryEntity(
      categoryName: 'Cultural',
      description: 'Cultural heritage and historical sites',
      icon: '🏛️',
      type: TravelCategoryType.cultural,
    ),
  ];
}

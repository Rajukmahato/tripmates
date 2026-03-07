import 'package:equatable/equatable.dart';

/// Categories for organizing checklist items
enum ChecklistCategory { documents, packing, health, booking, preparation }

/// Priority levels for checklist items
enum ChecklistPriority { low, medium, high }

/// Represents a single checklist item for trip preparation
class ChecklistItemEntity extends Equatable {
  final String id;
  final ChecklistCategory category;
  final String title;
  final bool isCompleted;
  final ChecklistPriority? priority;
  final DateTime? completedAt;
  final String? completedBy;
  final DateTime? createdAt;

  const ChecklistItemEntity({
    required this.id,
    required this.category,
    required this.title,
    this.isCompleted = false,
    this.priority,
    this.completedAt,
    this.completedBy,
    this.createdAt,
  });

  ChecklistItemEntity copyWith({
    String? id,
    ChecklistCategory? category,
    String? title,
    bool? isCompleted,
    ChecklistPriority? priority,
    DateTime? completedAt,
    String? completedBy,
    DateTime? createdAt,
  }) {
    return ChecklistItemEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    title,
    isCompleted,
    priority,
    completedAt,
    completedBy,
    createdAt,
  ];
}

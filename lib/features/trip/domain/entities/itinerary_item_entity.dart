import 'package:equatable/equatable.dart';

/// Represents a single item in trip itinerary
class ItineraryItemEntity extends Equatable {
  final String id;
  final int day; // Day number of the trip
  final DateTime date;
  final String title;
  final String? description;
  final String? location;
  final List<String>? activities; // Activities planned for this day
  final double? elevation; // Elevation in meters (for hiking/trekking)
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final bool isCompleted;

  const ItineraryItemEntity({
    required this.id,
    required this.day,
    required this.date,
    required this.title,
    this.description,
    this.location,
    this.activities,
    this.elevation,
    this.startTime,
    this.endTime,
    this.notes,
    this.isCompleted = false,
  });

  ItineraryItemEntity copyWith({
    String? id,
    int? day,
    DateTime? date,
    String? title,
    String? description,
    String? location,
    List<String>? activities,
    double? elevation,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    bool? isCompleted,
  }) {
    return ItineraryItemEntity(
      id: id ?? this.id,
      day: day ?? this.day,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      activities: activities ?? this.activities,
      elevation: elevation ?? this.elevation,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    day,
    date,
    title,
    description,
    location,
    activities,
    elevation,
    startTime,
    endTime,
    notes,
    isCompleted,
  ];
}

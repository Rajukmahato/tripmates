import 'package:equatable/equatable.dart';

/// Entity for trip management in admin
class AdminTripEntity extends Equatable {
  final String id;
  final String tripName;
  final String destination;
  final String creatorId;
  final String creatorName;
  final String? creatorAvatar;
  final String status; // 'planned', 'ongoing', 'completed', 'cancelled'
  final DateTime startDate;
  final DateTime endDate;
  final int participantsCount;
  final int maxParticipants;
  final int reportsCount;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;

  const AdminTripEntity({
    required this.id,
    required this.tripName,
    required this.destination,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatar,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.participantsCount,
    required this.maxParticipants,
    required this.reportsCount,
    required this.isFeatured,
    required this.isActive,
    required this.createdAt,
  });

  AdminTripEntity copyWith({
    String? id,
    String? tripName,
    String? destination,
    String? creatorId,
    String? creatorName,
    String? creatorAvatar,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? participantsCount,
    int? maxParticipants,
    int? reportsCount,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AdminTripEntity(
      id: id ?? this.id,
      tripName: tripName ?? this.tripName,
      destination: destination ?? this.destination,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantsCount: participantsCount ?? this.participantsCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      reportsCount: reportsCount ?? this.reportsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tripName,
    destination,
    creatorId,
    creatorName,
    creatorAvatar,
    status,
    startDate,
    endDate,
    participantsCount,
    maxParticipants,
    reportsCount,
    isFeatured,
    isActive,
    createdAt,
  ];
}

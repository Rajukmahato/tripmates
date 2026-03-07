import 'package:equatable/equatable.dart';

/// Entity for report management in admin
class AdminReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String reporterName;
  final String? reporterAvatar;
  final String reportedEntityType; // 'trip', 'user', 'review'
  final String reportedEntityId;
  final String? reportedEntityTitle; // Trip name, user name, etc.
  final String reason;
  final String? description;
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'
  final String? adminNotes;
  final String? reviewedBy; // Admin ID
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const AdminReportEntity({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    this.reporterAvatar,
    required this.reportedEntityType,
    required this.reportedEntityId,
    this.reportedEntityTitle,
    required this.reason,
    this.description,
    required this.status,
    this.adminNotes,
    this.reviewedBy,
    required this.createdAt,
    this.reviewedAt,
  });

  AdminReportEntity copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? reporterAvatar,
    String? reportedEntityType,
    String? reportedEntityId,
    String? reportedEntityTitle,
    String? reason,
    String? description,
    String? status,
    String? adminNotes,
    String? reviewedBy,
    DateTime? createdAt,
    DateTime? reviewedAt,
  }) {
    return AdminReportEntity(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterAvatar: reporterAvatar ?? this.reporterAvatar,
      reportedEntityType: reportedEntityType ?? this.reportedEntityType,
      reportedEntityId: reportedEntityId ?? this.reportedEntityId,
      reportedEntityTitle: reportedEntityTitle ?? this.reportedEntityTitle,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    reporterId,
    reporterName,
    reporterAvatar,
    reportedEntityType,
    reportedEntityId,
    reportedEntityTitle,
    reason,
    description,
    status,
    adminNotes,
    reviewedBy,
    createdAt,
    reviewedAt,
  ];
}

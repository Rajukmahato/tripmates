import 'package:equatable/equatable.dart';

/// Report reason enum
enum ReportReason {
  spam('Spam', 'This is spam or advertising'),
  inappropriate(
    'Inappropriate Content',
    'Contains offensive or inappropriate content',
  ),
  harassment('Harassment', 'Contains harassment or hate speech'),
  misinformation('Misinformation', 'Contains false or misleading information'),
  safety('Safety Concern', 'Raises safety or security concerns'),
  other('Other', 'Other reason');

  final String title;
  final String description;

  const ReportReason(this.title, this.description);
}

/// Report entity
class ReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedEntityType; // 'trip', 'user', 'review'
  final String reportedEntityId;
  final ReportReason reason;
  final String? description;
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ReportEntity({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedEntityType,
    required this.reportedEntityId,
    required this.reason,
    this.description,
    this.status = 'pending',
    required this.createdAt,
    this.resolvedAt,
  });

  ReportEntity copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? reportedEntityType,
    String? reportedEntityId,
    ReportReason? reason,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ReportEntity(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reportedEntityType: reportedEntityType ?? this.reportedEntityType,
      reportedEntityId: reportedEntityId ?? this.reportedEntityId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    reporterId,
    reporterName,
    reportedEntityType,
    reportedEntityId,
    reason,
    description,
    status,
    createdAt,
    resolvedAt,
  ];
}

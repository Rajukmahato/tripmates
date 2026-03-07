import 'package:tripmates/features/reports/domain/entities/report_entity.dart';

/// Report model for API responses
class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.reporterId,
    required super.reporterName,
    required super.reportedEntityType,
    required super.reportedEntityId,
    required super.reason,
    super.description,
    super.status = 'pending',
    required super.createdAt,
    super.resolvedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] ?? json['id'] ?? '',
      reporterId: json['reporterId'] ?? json['reporter']?['_id'] ?? '',
      reporterName: json['reporterName'] ?? json['reporter']?['name'] ?? '',
      reportedEntityType: json['reportedEntityType'] ?? '',
      reportedEntityId: json['reportedEntityId'] ?? '',
      reason: _reasonFromString(json['reason'] ?? 'other'),
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedEntityType': reportedEntityType,
      'reportedEntityId': reportedEntityId,
      'reason': reason.name,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  static ReportReason _reasonFromString(String reason) {
    switch (reason.toLowerCase()) {
      case 'spam':
        return ReportReason.spam;
      case 'inappropriate':
        return ReportReason.inappropriate;
      case 'harassment':
        return ReportReason.harassment;
      case 'misinformation':
        return ReportReason.misinformation;
      case 'safety':
        return ReportReason.safety;
      default:
        return ReportReason.other;
    }
  }

  factory ReportModel.fromEntity(ReportEntity entity) {
    return ReportModel(
      id: entity.id,
      reporterId: entity.reporterId,
      reporterName: entity.reporterName,
      reportedEntityType: entity.reportedEntityType,
      reportedEntityId: entity.reportedEntityId,
      reason: entity.reason,
      description: entity.description,
      status: entity.status,
      createdAt: entity.createdAt,
      resolvedAt: entity.resolvedAt,
    );
  }
}

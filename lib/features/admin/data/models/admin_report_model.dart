import 'package:tripmates/features/admin/domain/entities/admin_report_entity.dart';

/// Model for admin report management
class AdminReportModel extends AdminReportEntity {
  const AdminReportModel({
    required super.id,
    required super.reporterId,
    required super.reporterName,
    super.reporterAvatar,
    required super.reportedEntityType,
    required super.reportedEntityId,
    super.reportedEntityTitle,
    required super.reason,
    super.description,
    required super.status,
    super.adminNotes,
    super.reviewedBy,
    required super.createdAt,
    super.reviewedAt,
  });

  factory AdminReportModel.fromJson(Map<String, dynamic> json) {
    final reporter = json['reporter'] as Map<String, dynamic>?;

    return AdminReportModel(
      id: json['_id'] as String? ?? json['id'] as String,
      reporterId:
          reporter?['_id'] as String? ?? json['reporterId'] as String? ?? '',
      reporterName:
          reporter?['fullName'] as String? ??
          json['reporterName'] as String? ??
          '',
      reporterAvatar: reporter?['profilePicture'] as String?,
      reportedEntityType: json['reportedEntityType'] as String? ?? '',
      reportedEntityId: json['reportedEntityId'] as String? ?? '',
      reportedEntityTitle: json['reportedEntityTitle'] as String?,
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['adminNotes'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterAvatar': reporterAvatar,
      'reportedEntityType': reportedEntityType,
      'reportedEntityId': reportedEntityId,
      'reportedEntityTitle': reportedEntityTitle,
      'reason': reason,
      'description': description,
      'status': status,
      'adminNotes': adminNotes,
      'reviewedBy': reviewedBy,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory AdminReportModel.fromEntity(AdminReportEntity entity) {
    return AdminReportModel(
      id: entity.id,
      reporterId: entity.reporterId,
      reporterName: entity.reporterName,
      reporterAvatar: entity.reporterAvatar,
      reportedEntityType: entity.reportedEntityType,
      reportedEntityId: entity.reportedEntityId,
      reportedEntityTitle: entity.reportedEntityTitle,
      reason: entity.reason,
      description: entity.description,
      status: entity.status,
      adminNotes: entity.adminNotes,
      reviewedBy: entity.reviewedBy,
      createdAt: entity.createdAt,
      reviewedAt: entity.reviewedAt,
    );
  }
}

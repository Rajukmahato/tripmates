import 'package:tripmates/features/admin/domain/entities/report_entity.dart';

class ReportApiModel {
  final String id;
  final String reportedUserId;
  final String reportedUserName;
  final String reportedUserAvatar;
  final String reportingUserId;
  final String reportingUserName;
  final String type;
  final String reason;
  final String status;
  final String? notes;
  final List<String>? evidence;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  ReportApiModel({
    required this.id,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reportedUserAvatar,
    required this.reportingUserId,
    required this.reportingUserName,
    required this.type,
    required this.reason,
    required this.status,
    this.notes,
    this.evidence,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory ReportApiModel.fromJson(Map<String, dynamic> json) {
    return ReportApiModel(
      id: json['_id'] ?? json['id'] ?? '',
      reportedUserId: json['reportedUserId'] ?? '',
      reportedUserName: json['reportedUserName'] ?? '',
      reportedUserAvatar: json['reportedUserAvatar'] ?? '',
      reportingUserId: json['reportingUserId'] ?? '',
      reportingUserName: json['reportingUserName'] ?? '',
      type: json['type'] ?? 'other',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      evidence: json['evidence'] != null
          ? List<String>.from(json['evidence'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'].toString())
          : null,
      resolvedBy: json['resolvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'reportedUserAvatar': reportedUserAvatar,
      'reportingUserId': reportingUserId,
      'reportingUserName': reportingUserName,
      'type': type,
      'reason': reason,
      'status': status,
      'notes': notes,
      'evidence': evidence,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
    };
  }

  ReportEntity toEntity() {
    return ReportEntity(
      id: id,
      reportedUserId: reportedUserId,
      reportedUserName: reportedUserName,
      reportedUserAvatar: reportedUserAvatar,
      reportingUserId: reportingUserId,
      reportingUserName: reportingUserName,
      type: _parseReportType(type),
      reason: reason,
      status: _parseReportStatus(status),
      notes: notes,
      evidence: evidence,
      createdAt: createdAt,
      resolvedAt: resolvedAt,
      resolvedBy: resolvedBy,
    );
  }

  factory ReportApiModel.fromEntity(ReportEntity entity) {
    return ReportApiModel(
      id: entity.id,
      reportedUserId: entity.reportedUserId,
      reportedUserName: entity.reportedUserName,
      reportedUserAvatar: entity.reportedUserAvatar,
      reportingUserId: entity.reportingUserId,
      reportingUserName: entity.reportingUserName,
      type: entity.type.toString().split('.').last,
      reason: entity.reason,
      status: entity.status.toString().split('.').last,
      notes: entity.notes,
      evidence: entity.evidence,
      createdAt: entity.createdAt,
      resolvedAt: entity.resolvedAt,
      resolvedBy: entity.resolvedBy,
    );
  }

  static ReportType _parseReportType(String type) {
    switch (type) {
      case 'inappropriate_behavior':
        return ReportType.inappropriate_behavior;
      case 'harassment':
        return ReportType.harassment;
      case 'fraud':
        return ReportType.fraud;
      case 'safety_concern':
        return ReportType.safety_concern;
      case 'offensive_content':
        return ReportType.offensive_content;
      case 'spam':
        return ReportType.spam;
      default:
        return ReportType.other;
    }
  }

  static ReportStatus _parseReportStatus(String status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'under_review':
        return ReportStatus.under_review;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }
}

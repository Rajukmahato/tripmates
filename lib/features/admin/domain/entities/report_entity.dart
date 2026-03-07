// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum ReportType {
  inappropriate_behavior,
  harassment,
  fraud,
  safety_concern,
  offensive_content,
  spam,
  other,
}

enum ReportStatus { pending, under_review, resolved, dismissed }

class ReportEntity extends Equatable {
  final String id;
  final String reportedUserId;
  final String reportedUserName;
  final String reportedUserAvatar;
  final String reportingUserId;
  final String reportingUserName;
  final ReportType type;
  final String reason;
  final ReportStatus status;
  final String? notes;
  final List<String>? evidence; // URLs to evidence images/screenshots
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  const ReportEntity({
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

  @override
  List<Object?> get props => [
    id,
    reportedUserId,
    reportedUserName,
    reportedUserAvatar,
    reportingUserId,
    reportingUserName,
    type,
    reason,
    status,
    notes,
    evidence,
    createdAt,
    resolvedAt,
    resolvedBy,
  ];

  ReportEntity copyWith({
    String? id,
    String? reportedUserId,
    String? reportedUserName,
    String? reportedUserAvatar,
    String? reportingUserId,
    String? reportingUserName,
    ReportType? type,
    String? reason,
    ReportStatus? status,
    String? notes,
    List<String>? evidence,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) {
    return ReportEntity(
      id: id ?? this.id,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedUserName: reportedUserName ?? this.reportedUserName,
      reportedUserAvatar: reportedUserAvatar ?? this.reportedUserAvatar,
      reportingUserId: reportingUserId ?? this.reportingUserId,
      reportingUserName: reportingUserName ?? this.reportingUserName,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      evidence: evidence ?? this.evidence,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }
}

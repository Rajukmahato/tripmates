import 'package:equatable/equatable.dart';
import 'package:tripmates/features/reports/domain/entities/report_entity.dart';

/// State for reports feature
class ReportState extends Equatable {
  final List<ReportEntity> reports;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  ReportState copyWith({
    List<ReportEntity>? reports,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  @override
  List<Object?> get props => [reports, isLoading, isSubmitting, error];
}

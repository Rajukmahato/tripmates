import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/reports/domain/entities/report_entity.dart';
import 'package:tripmates/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:tripmates/features/reports/domain/usecases/submit_report_usecase.dart';
import 'package:tripmates/features/reports/presentation/state/report_state.dart';

/// ViewModel for reports
class ReportViewmodel extends Notifier<ReportState> {
  late final SubmitReportUseCase _submitReportUseCase;
  late final GetMyReportsUseCase _getMyReportsUseCase;

  @override
  ReportState build() {
    _submitReportUseCase = ref.watch(submitReportUseCaseProvider);
    _getMyReportsUseCase = ref.watch(getMyReportsUseCaseProvider);
    return const ReportState();
  }

  /// Load my reports
  Future<void> loadMyReports({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _getMyReportsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (reports) {
        state = state.copyWith(reports: reports, isLoading: false, error: null);
      },
    );
  }

  /// Submit a report
  Future<bool> submitReport({
    required String reportedEntityType,
    required String reportedEntityId,
    required ReportReason reason,
    String? description,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    final result = await _submitReportUseCase(
      reportedEntityType: reportedEntityType,
      reportedEntityId: reportedEntityId,
      reason: reason,
      description: description,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, error: failure.message);
        return false;
      },
      (report) {
        state = state.copyWith(
          reports: [report, ...state.reports],
          isSubmitting: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Reset state
  void resetState() {
    state = const ReportState();
  }
}

/// Provider
final reportViewmodelProvider = NotifierProvider<ReportViewmodel, ReportState>(
  () => ReportViewmodel(),
);

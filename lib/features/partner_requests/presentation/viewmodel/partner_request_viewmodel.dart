import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/accept_request_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/reject_request_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/cancel_request_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/get_requests_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/send_request_usecase.dart';
import 'package:tripmates/features/partner_requests/presentation/state/partner_request_state.dart';

/// ViewModel for partner requests
class PartnerRequestViewmodel extends Notifier<PartnerRequestState> {
  late final SendRequestUseCase _sendRequestUseCase;
  late final GetRequestsUseCase _getRequestsUseCase;
  late final AcceptRequestUseCase _acceptRequestUseCase;
  late final RejectRequestUseCase _rejectRequestUseCase;
  late final CancelRequestUseCase _cancelRequestUseCase;

  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(seconds: 30);
  bool _isFetching = false;

  @override
  PartnerRequestState build() {
    _sendRequestUseCase = ref.watch(sendRequestUseCaseProvider);
    _getRequestsUseCase = ref.watch(getRequestsUseCaseProvider);
    _acceptRequestUseCase = ref.watch(acceptRequestUseCaseProvider);
    _rejectRequestUseCase = ref.watch(rejectRequestUseCaseProvider);
    _cancelRequestUseCase = ref.watch(cancelRequestUseCaseProvider);
    return const PartnerRequestState();
  }

  /// Load partner requests
  Future<void> loadRequests({bool refresh = false}) async {
    // Prevent duplicate simultaneous requests
    if (_isFetching) {
      log('loadRequests: Already fetching, skipping duplicate call');
      return;
    }

    // Use cache if available and not forcing refresh
    if (!refresh && _lastFetchTime != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
      if (timeSinceLastFetch < _cacheDuration) {
        log(
          'loadRequests: Using cached data (${timeSinceLastFetch.inSeconds}s old)',
        );
        return;
      }
    }

    if (state.isLoading && !refresh) return;

    _isFetching = true;
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getRequestsUseCase(
      filter: state.selectedFilter == 'all' ? null : state.selectedFilter,
      status: state.selectedStatus,
    );

    result.fold(
      (failure) {
        _isFetching = false;
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (requests) {
        _isFetching = false;
        _lastFetchTime = DateTime.now();
        final pendingCount = requests
            .where(
              (req) =>
                  req.status == RequestStatus.pending &&
                  state.selectedFilter != 'sent',
            )
            .length;
        state = state.copyWith(
          requests: requests,
          pendingCount: pendingCount,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Send a partner request
  Future<bool> sendRequest({
    required String receiverId,
    required String tripId,
    String? message,
  }) async {
    final result = await _sendRequestUseCase(
      receiverId: receiverId,
      tripId: tripId,
      message: message,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (request) {
        // Add to list if showing sent requests
        if (state.selectedFilter == 'all' || state.selectedFilter == 'sent') {
          state = state.copyWith(requests: [request, ...state.requests]);
        }
        return true;
      },
    );
  }

  /// Accept a partner request
  Future<bool> acceptRequest(String requestId) async {
    final result = await _acceptRequestUseCase(requestId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedRequest) {
        final updatedList = state.requests.map((req) {
          return req.id == requestId ? updatedRequest : req;
        }).toList();

        state = state.copyWith(
          requests: updatedList,
          pendingCount: state.pendingCount > 0 ? state.pendingCount - 1 : 0,
        );
        return true;
      },
    );
  }

  /// Reject a partner request
  Future<bool> rejectRequest(String requestId) async {
    log('rejectRequest: Rejecting request=$requestId');
    final result = await _rejectRequestUseCase(requestId);

    return result.fold(
      (failure) {
        log('rejectRequest: Error - ${failure.message}');
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedRequest) {
        log('rejectRequest: Success!');
        final updatedList = state.requests.map((req) {
          return req.id == requestId ? updatedRequest : req;
        }).toList();

        state = state.copyWith(
          requests: updatedList,
          pendingCount: state.pendingCount > 0 ? state.pendingCount - 1 : 0,
        );
        return true;
      },
    );
  }

  /// Cancel a sent partner request
  Future<bool> cancelRequest(String requestId) async {
    log('cancelRequest: Canceling request=$requestId');
    final result = await _cancelRequestUseCase(requestId);

    return result.fold(
      (failure) {
        log('cancelRequest: Error - ${failure.message}');
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        log('cancelRequest: Success!');
        // Remove request from list
        final updatedList = state.requests
            .where((req) => req.id != requestId)
            .toList();

        state = state.copyWith(requests: updatedList);
        return true;
      },
    );
  }

  /// Set filter (all, sent, received)
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
    _lastFetchTime = null; // Clear cache on filter change
    loadRequests(refresh: true);
  }

  /// Set status filter (pending, accepted, rejected, null)
  void setStatusFilter(String? status) {
    state = state.copyWith(selectedStatus: status);
    _lastFetchTime = null; // Clear cache on filter change
    loadRequests(refresh: true);
  }

  /// Reset state
  void resetState() {
    state = const PartnerRequestState();
  }
}

/// Provider
final partnerRequestViewmodelProvider =
    NotifierProvider<PartnerRequestViewmodel, PartnerRequestState>(
      () => PartnerRequestViewmodel(),
    );

/// Pending count provider
final pendingRequestCountProvider = Provider<int>((ref) {
  final state = ref.watch(partnerRequestViewmodelProvider);
  return state.pendingCount;
});

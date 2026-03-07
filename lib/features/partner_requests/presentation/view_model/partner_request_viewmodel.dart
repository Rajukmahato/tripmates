import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/send_request_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/accept_request_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/reject_request_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/cancel_request_usecase.dart';
import 'package:tripmates/features/partner_requests/domain/usecases/get_requests_usecase.dart';
import 'package:tripmates/features/partner_requests/presentation/state/partner_request_state.dart';

final partnerRequestViewModelProvider =
    NotifierProvider<PartnerRequestViewModel, PartnerRequestState>(
      PartnerRequestViewModel.new,
    );

class PartnerRequestViewModel extends Notifier<PartnerRequestState> {
  late final SendRequestUseCase _sendRequestUseCase;
  late final AcceptRequestUseCase _acceptRequestUseCase;
  late final RejectRequestUseCase _rejectRequestUseCase;
  late final CancelRequestUseCase _cancelRequestUseCase;
  late final GetRequestsUseCase _getRequestsUseCase;

  @override
  PartnerRequestState build() {
    _sendRequestUseCase = ref.read(sendRequestUseCaseProvider);
    _acceptRequestUseCase = ref.read(acceptRequestUseCaseProvider);
    _rejectRequestUseCase = ref.read(rejectRequestUseCaseProvider);
    _cancelRequestUseCase = ref.read(cancelRequestUseCaseProvider);
    _getRequestsUseCase = ref.read(getRequestsUseCaseProvider);
    return const PartnerRequestState();
  }

  /// Send a partner request
  Future<bool> sendRequest({
    required String receiverId,
    required String tripId,
    String? message,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    log(
      'sendRequest: Sending request to receiverId=$receiverId, tripId=$tripId',
    );

    final result = await _sendRequestUseCase.call(
      receiverId: receiverId,
      tripId: tripId,
      message: message,
    );

    final success = result.fold(
      (failure) {
        log('sendRequest: Error - ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (request) {
        log('sendRequest: Success! Sent request with id=${request.id}');
        state = state.copyWith(
          isLoading: false,
          requests: [...state.requests, request],
          error: null,
        );
        return true;
      },
    );

    return success;
  }

  /// Accept a partner request
  Future<bool> acceptRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    log('acceptRequest: Accepting request=$requestId');

    final result = await _acceptRequestUseCase.call(requestId);

    final success = result.fold(
      (failure) {
        log('acceptRequest: Error - ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedRequest) {
        log('acceptRequest: Success! Accepted request');
        // Update request in list
        final updatedRequests = state.requests.map((req) {
          if (req.id == requestId) {
            return updatedRequest;
          }
          return req;
        }).toList();
        state = state.copyWith(
          isLoading: false,
          requests: updatedRequests,
          error: null,
        );
        return true;
      },
    );

    return success;
  }

  /// Reject a partner request
  Future<bool> rejectRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    log('rejectRequest: Rejecting request=$requestId');

    final result = await _rejectRequestUseCase.call(requestId);

    final success = result.fold(
      (failure) {
        log('rejectRequest: Error - ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedRequest) {
        log('rejectRequest: Success! Rejected request');
        // Update request in list
        final updatedRequests = state.requests.map((req) {
          if (req.id == requestId) {
            return updatedRequest;
          }
          return req;
        }).toList();
        state = state.copyWith(
          isLoading: false,
          requests: updatedRequests,
          error: null,
        );
        return true;
      },
    );

    return success;
  }

  /// Cancel a sent partner request
  Future<bool> cancelRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    log('cancelRequest: Canceling request=$requestId');

    final result = await _cancelRequestUseCase.call(requestId);

    final success = result.fold(
      (failure) {
        log('cancelRequest: Error - ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        log('cancelRequest: Success! Canceled request');
        // Remove request from list
        final updatedRequests = state.requests
            .where((req) => req.id != requestId)
            .toList();
        state = state.copyWith(
          isLoading: false,
          requests: updatedRequests,
          error: null,
        );
        return true;
      },
    );

    return success;
  }

  /// Load partner requests with optional filters
  Future<void> loadRequests({
    String filter = 'all',
    String? status,
    bool refresh = false,
  }) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);
    log('loadRequests: Loading requests with filter=$filter, status=$status');

    final result = await _getRequestsUseCase.call(
      filter: filter,
      status: status,
    );

    result.fold(
      (failure) {
        log('loadRequests: Error - ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (requests) {
        log('loadRequests: Success! Got ${requests.length} requests');
        state = state.copyWith(
          isLoading: false,
          requests: requests,
          selectedFilter: filter,
          selectedStatus: status,
          error: null,
        );
      },
    );
  }

  /// Load requests for a specific trip
  Future<void> loadRequestsByTrip(String tripId) async {
    state = state.copyWith(isLoading: true, error: null);
    log('loadRequestsByTrip: Loading requests for trip=$tripId');

    final result = await _getRequestsUseCase.getByTrip(tripId);

    result.fold(
      (failure) {
        log('loadRequestsByTrip: Error - ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (requests) {
        log('loadRequestsByTrip: Success! Got ${requests.length} requests');
        state = state.copyWith(
          isLoading: false,
          requests: requests,
          error: null,
        );
      },
    );
  }

  /// Get the count of pending requests
  Future<void> getPendingCount() async {
    log('getPendingCount: Fetching pending count');

    final result = await _getRequestsUseCase.getPendingCount();

    result.fold(
      (failure) {
        log('getPendingCount: Error - ${failure.message}');
        // Don't update state with error for this operation
      },
      (count) {
        log('getPendingCount: Success! Count=$count');
        state = state.copyWith(pendingCount: count);
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void resetState() {
    state = const PartnerRequestState();
  }
}

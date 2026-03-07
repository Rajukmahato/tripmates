import 'package:equatable/equatable.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';

/// State for partner requests feature
class PartnerRequestState extends Equatable {
  final List<PartnerRequestEntity> requests;
  final int pendingCount;
  final bool isLoading;
  final String? error;
  final String selectedFilter; // 'all', 'sent', 'received'
  final String? selectedStatus; // 'pending', 'accepted', 'rejected', null = all

  const PartnerRequestState({
    this.requests = const [],
    this.pendingCount = 0,
    this.isLoading = false,
    this.error,
    this.selectedFilter = 'all',
    this.selectedStatus,
  });

  PartnerRequestState copyWith({
    List<PartnerRequestEntity>? requests,
    int? pendingCount,
    bool? isLoading,
    String? error,
    String? selectedFilter,
    String? selectedStatus,
  }) {
    return PartnerRequestState(
      requests: requests ?? this.requests,
      pendingCount: pendingCount ?? this.pendingCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }

  List<PartnerRequestEntity> get filteredRequests {
    return requests;
  }

  @override
  List<Object?> get props => [
    requests,
    pendingCount,
    isLoading,
    error,
    selectedFilter,
    selectedStatus,
  ];
}

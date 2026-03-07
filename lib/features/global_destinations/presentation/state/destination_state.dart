import 'package:equatable/equatable.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';

enum DestinationStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
  toggled,
}

class DestinationState extends Equatable {
  final DestinationStatus status;
  final List<GlobalDestinationEntity> destinations;
  final GlobalDestinationEntity? selectedDestination;
  final Map<String, dynamic>? stats;
  final String? errorMessage;
  final String? searchQuery;

  const DestinationState({
    this.status = DestinationStatus.initial,
    this.destinations = const [],
    this.selectedDestination,
    this.stats,
    this.errorMessage,
    this.searchQuery,
  });

  DestinationState copyWith({
    DestinationStatus? status,
    List<GlobalDestinationEntity>? destinations,
    GlobalDestinationEntity? selectedDestination,
    Map<String, dynamic>? stats,
    String? errorMessage,
    String? searchQuery,
  }) {
    return DestinationState(
      status: status ?? this.status,
      destinations: destinations ?? this.destinations,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      stats: stats ?? this.stats,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    destinations,
    selectedDestination,
    stats,
    errorMessage,
    searchQuery,
  ];
}

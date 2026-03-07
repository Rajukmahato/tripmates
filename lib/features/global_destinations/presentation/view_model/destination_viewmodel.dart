import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/domain/usecases/get_all_destinations_usecase.dart';
import 'package:tripmates/features/global_destinations/domain/usecases/search_destinations_usecase.dart';
import 'package:tripmates/features/global_destinations/domain/usecases/get_destination_by_id_usecase.dart';
import 'package:tripmates/features/global_destinations/domain/usecases/create_destination_usecase.dart';
import 'package:tripmates/features/global_destinations/domain/usecases/update_destination_usecase.dart';
import 'package:tripmates/features/global_destinations/domain/usecases/delete_destination_usecase.dart';
import 'package:tripmates/features/global_destinations/domain/usecases/toggle_destination_status_usecase.dart';
import 'package:tripmates/features/global_destinations/domain/usecases/get_destination_stats_usecase.dart';
import 'package:tripmates/features/global_destinations/presentation/state/destination_state.dart';

/// Provider for DestinationViewModel
final destinationViewModelProvider =
    NotifierProvider<DestinationViewModel, DestinationState>(
      DestinationViewModel.new,
    );

/// ViewModel for managing global destinations
class DestinationViewModel extends Notifier<DestinationState> {
  late final GetAllDestinationsUseCase _getAllDestinationsUseCase;
  late final SearchDestinationsUseCase _searchDestinationsUseCase;
  late final GetDestinationByIdUseCase _getDestinationByIdUseCase;
  late final CreateDestinationUseCase _createDestinationUseCase;
  late final UpdateDestinationUseCase _updateDestinationUseCase;
  late final DeleteDestinationUseCase _deleteDestinationUseCase;
  late final ToggleDestinationStatusUseCase _toggleDestinationStatusUseCase;
  late final GetDestinationStatsUseCase _getDestinationStatsUseCase;

  @override
  DestinationState build() {
    _getAllDestinationsUseCase = ref.read(getAllDestinationsUseCaseProvider);
    _searchDestinationsUseCase = ref.read(searchDestinationsUseCaseProvider);
    _getDestinationByIdUseCase = ref.read(getDestinationByIdUseCaseProvider);
    _createDestinationUseCase = ref.read(createDestinationUseCaseProvider);
    _updateDestinationUseCase = ref.read(updateDestinationUseCaseProvider);
    _deleteDestinationUseCase = ref.read(deleteDestinationUseCaseProvider);
    _toggleDestinationStatusUseCase = ref.read(
      toggleDestinationStatusUseCaseProvider,
    );
    _getDestinationStatsUseCase = ref.read(getDestinationStatsUseCaseProvider);
    return const DestinationState();
  }

  // User-facing methods

  /// Load all destinations (user view)
  Future<void> getAllDestinations({bool includeInactive = false}) async {
    state = state.copyWith(status: DestinationStatus.loading);
    log('getAllDestinations: Fetching destinations');

    final result = await _getAllDestinationsUseCase(
      GetAllDestinationsParams(includeInactive: includeInactive),
    );

    result.fold(
      (failure) {
        log('getAllDestinations: Error - ${failure.message}');
        state = state.copyWith(
          status: DestinationStatus.error,
          errorMessage: failure.message,
        );
      },
      (destinations) {
        log(
          'getAllDestinations: Success! Got ${destinations.length} destinations',
        );
        state = state.copyWith(
          status: DestinationStatus.loaded,
          destinations: destinations,
        );
      },
    );
  }

  /// Search destinations by name
  Future<void> searchDestinations({
    required String query,
    bool includeInactive = false,
  }) async {
    state = state.copyWith(
      status: DestinationStatus.loading,
      searchQuery: query,
    );
    log('searchDestinations: Searching for "$query"');

    final result = await _searchDestinationsUseCase(
      SearchDestinationsParams(query: query, includeInactive: includeInactive),
    );

    result.fold(
      (failure) {
        log('searchDestinations: Error - ${failure.message}');
        state = state.copyWith(
          status: DestinationStatus.error,
          errorMessage: failure.message,
        );
      },
      (destinations) {
        log('searchDestinations: Found ${destinations.length} destinations');
        state = state.copyWith(
          status: DestinationStatus.loaded,
          destinations: destinations,
        );
      },
    );
  }

  /// Get destination by ID and set as selected
  Future<void> getDestinationById(String id) async {
    state = state.copyWith(status: DestinationStatus.loading);
    log('getDestinationById: Fetching destination $id');

    final result = await _getDestinationByIdUseCase(
      GetDestinationByIdParams(id: id),
    );

    result.fold(
      (failure) {
        log('getDestinationById: Error - ${failure.message}');
        state = state.copyWith(
          status: DestinationStatus.error,
          errorMessage: failure.message,
        );
      },
      (destination) {
        log('getDestinationById: Success! Got ${destination.name}');
        state = state.copyWith(
          status: DestinationStatus.loaded,
          selectedDestination: destination,
        );
      },
    );
  }

  /// Select a destination from the list
  void selectDestination(GlobalDestinationEntity destination) {
    state = state.copyWith(selectedDestination: destination);
  }

  /// Clear selected destination
  void clearSelectedDestination() {
    state = state.copyWith(selectedDestination: null);
  }

  /// Clear search query and reload all destinations
  Future<void> clearSearch() async {
    state = state.copyWith(searchQuery: null);
    await getAllDestinations();
  }

  // Admin-only methods

  /// Create a new destination (Admin only)
  Future<void> createDestination(Map<String, dynamic> data) async {
    state = state.copyWith(status: DestinationStatus.loading);
    log('createDestination: Creating new destination');

    final result = await _createDestinationUseCase(
      CreateDestinationParams(data: data),
    );

    result.fold(
      (failure) {
        log('createDestination: Error - ${failure.message}');
        state = state.copyWith(
          status: DestinationStatus.error,
          errorMessage: failure.message,
        );
      },
      (destination) {
        log('createDestination: Success! Created ${destination.name}');
        state = state.copyWith(status: DestinationStatus.created);
        getAllDestinations(includeInactive: true); // Reload list for admin
      },
    );
  }

  /// Update an existing destination (Admin only)
  Future<void> updateDestination(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: DestinationStatus.loading);
    log('updateDestination: Updating destination $id');

    final result = await _updateDestinationUseCase(
      UpdateDestinationParams(id: id, data: data),
    );

    result.fold(
      (failure) {
        log('updateDestination: Error - ${failure.message}');
        state = state.copyWith(
          status: DestinationStatus.error,
          errorMessage: failure.message,
        );
      },
      (destination) {
        log('updateDestination: Success! Updated ${destination.name}');
        state = state.copyWith(status: DestinationStatus.updated);
        getAllDestinations(includeInactive: true); // Reload list for admin
      },
    );
  }

  /// Delete a destination (Admin only)
  Future<void> deleteDestination(String id) async {
    state = state.copyWith(status: DestinationStatus.loading);
    log('deleteDestination: Deleting destination $id');

    final result = await _deleteDestinationUseCase(
      DeleteDestinationParams(id: id),
    );

    result.fold(
      (failure) {
        log('deleteDestination: Error - ${failure.message}');
        state = state.copyWith(
          status: DestinationStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        log('deleteDestination: Success!');
        state = state.copyWith(status: DestinationStatus.deleted);
        getAllDestinations(includeInactive: true); // Reload list for admin
      },
    );
  }

  /// Toggle destination active/inactive status (Admin only)
  Future<void> toggleDestinationStatus(String id) async {
    state = state.copyWith(status: DestinationStatus.loading);
    log('toggleDestinationStatus: Toggling status for $id');

    final result = await _toggleDestinationStatusUseCase(
      ToggleDestinationStatusParams(id: id),
    );

    result.fold(
      (failure) {
        log('toggleDestinationStatus: Error - ${failure.message}');
        state = state.copyWith(
          status: DestinationStatus.error,
          errorMessage: failure.message,
        );
      },
      (destination) {
        log(
          'toggleDestinationStatus: Success! New status: ${destination.isActive}',
        );
        state = state.copyWith(status: DestinationStatus.toggled);
        getAllDestinations(includeInactive: true); // Reload list for admin
      },
    );
  }

  /// Load destination statistics (Admin only)
  Future<void> loadDestinationStats() async {
    state = state.copyWith(status: DestinationStatus.loading);
    log('loadDestinationStats: Loading stats');

    final result = await _getDestinationStatsUseCase();

    result.fold(
      (failure) {
        log('loadDestinationStats: Error - ${failure.message}');
        state = state.copyWith(
          status: DestinationStatus.error,
          errorMessage: failure.message,
        );
      },
      (stats) {
        log('loadDestinationStats: Success! Got stats: $stats');
        state = state.copyWith(status: DestinationStatus.loaded, stats: stats);
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/trip/domain/usecases/create_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/delete_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_all_trips_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_my_trips_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_joined_trips_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/update_trip_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/send_join_request_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_trip_itinerary_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/update_trip_itinerary_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/get_trip_checklist_usecase.dart';
import 'package:tripmates/features/trip/domain/usecases/update_trip_checklist_usecase.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/entities/itinerary_item_entity.dart';
import 'package:tripmates/features/trip/domain/entities/checklist_item_entity.dart';
import 'package:tripmates/features/trip/presentation/state/trip_state.dart';
import 'package:tripmates/features/trip/presentation/widgets/advanced_filters_widget.dart';

final tripViewModelProvider = NotifierProvider<TripViewModel, TripState>(
  TripViewModel.new,
);

class TripViewModel extends Notifier<TripState> {
  late final GetAllTripsUsecase _getAllTripsUsecase;
  late final GetMyTripsUsecase _getMyTripsUsecase;
  late final GetJoinedTripsUsecase _getJoinedTripsUsecase;
  late final CreateTripUsecase _createTripUsecase;
  late final UpdateTripUsecase _updateTripUsecase;
  late final DeleteTripUsecase _deleteTripUsecase;
  late final GetTripItineraryUsecase _getTripItineraryUsecase;
  late final UpdateTripItineraryUsecase _updateTripItineraryUsecase;
  late final GetTripChecklistUsecase _getTripChecklistUsecase;
  late final UpdateTripChecklistUsecase _updateTripChecklistUsecase;

  @override
  TripState build() {
    _getAllTripsUsecase = ref.read(getAllTripsUsecaseProvider);
    _getMyTripsUsecase = ref.read(getMyTripsUsecaseProvider);
    _getJoinedTripsUsecase = ref.read(getJoinedTripsUsecaseProvider);
    _createTripUsecase = ref.read(createTripUsecaseProvider);
    _updateTripUsecase = ref.read(updateTripUsecaseProvider);
    _deleteTripUsecase = ref.read(deleteTripUsecaseProvider);
    _getTripItineraryUsecase = ref.read(getTripItineraryUsecaseProvider);
    _updateTripItineraryUsecase = ref.read(updateTripItineraryUsecaseProvider);
    _getTripChecklistUsecase = ref.read(getTripChecklistUsecaseProvider);
    _updateTripChecklistUsecase = ref.read(updateTripChecklistUsecaseProvider);
    return const TripState();
  }

  Future<void> getAllTrips() async {
    state = state.copyWith(status: TripStateStatus.loading);
    log('getAllTrips: Fetching trips');

    final result = await _getAllTripsUsecase();

    result.fold(
      (failure) {
        log('getAllTrips: Error - ${failure.message}');
        state = state.copyWith(
          status: TripStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (trips) {
        log('getAllTrips: Success! Got ${trips.length} trips');
        if (trips.isNotEmpty) {
          log(
            'Sample trip: ${trips[0].tripName} - NPR ${trips[0].budget}, ${trips[0].groupSizeMax} members, ${trips[0].averageRating}★',
          );
        }
        state = state.copyWith(status: TripStateStatus.loaded, trips: trips);
        log('State updated with ${state.trips.length} trips');
      },
    );
  }

  Future<void> getMyTrips(String userId) async {
    state = state.copyWith(status: TripStateStatus.loading);

    // Get trips created by user
    final createdTripsResult = await _getMyTripsUsecase(
      GetMyTripsParams(userId: userId),
    );

    // Get trips where user is a member
    final joinedTripsResult = await _getJoinedTripsUsecase(
      GetJoinedTripsParams(userId: userId),
    );

    // Combine both lists and remove duplicates
    List<TripEntity> allTrips = [];

    createdTripsResult.fold(
      (failure) => null,
      (trips) => allTrips.addAll(trips),
    );

    // Handle joined trips - if the endpoint fails (404), use getAllTrips as fallback
    bool joinedTripsFailed = false;
    joinedTripsResult.fold(
      (failure) {
        log('getMyTrips: Joined trips endpoint failed - ${failure.message}');
        joinedTripsFailed = true;
      },
      (trips) {
        // Add joined trips that aren't already in the list
        for (final trip in trips) {
          if (!allTrips.any((t) => t.tripId == trip.tripId)) {
            allTrips.add(trip);
          }
        }
      },
    );

    // If joined trips failed, fallback to getAllTrips
    if (joinedTripsFailed) {
      log('getMyTrips: Using getAllTrips fallback to get all trips');
      final allTripsResult = await _getAllTripsUsecase();
      allTripsResult.fold(
        (failure) => log(
          'getMyTrips: getAllTrips fallback also failed - ${failure.message}',
        ),
        (trips) {
          // Add all trips that aren't already in the list
          // Frontend will filter by membership using _getUserMemberTrips
          for (final trip in trips) {
            if (!allTrips.any((t) => t.tripId == trip.tripId)) {
              allTrips.add(trip);
            }
          }
          log(
            'getMyTrips: Added ${trips.length} trips from getAllTrips fallback',
          );
        },
      );
    }

    // Sort by creation date (newest first)
    allTrips.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    // Update state with combined trips
    state = state.copyWith(
      status: TripStateStatus.loaded,
      trips: allTrips,
      errorMessage: null,
    );
  }

  /// Get trips the user has joined (user is a member)
  Future<void> getJoinedTrips(String userId) async {
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _getJoinedTripsUsecase(
      GetJoinedTripsParams(userId: userId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: failure.message,
      ),
      (trips) =>
          state = state.copyWith(status: TripStateStatus.loaded, trips: trips),
    );
  }

  Future<void> createTrip({
    required String tripName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required TripStatus status,
    required String userId,
    String? description,
    String? category,
    String? media,
    List<String>? destinationIds,
    // Required backend fields
    String? travelType,
    int? groupSizeMin,
    int? groupSizeMax,
    // Web parity fields
    double? budget,
    double? distanceMin,
    double? distanceMax,
    String? distanceUnit,
    int? durationMinHours,
    int? durationMaxHours,
    String? difficultyLevel,
    String? fitnessLevel,
    String? physicalDemand,
    String? skillLevelRequired,
    String? bestSeason,
    List<String>? bestMonths,
    int? elevationMin,
    int? elevationMax,
    String? elevationUnit,
    List<String>? inclusions,
    List<String>? exclusions,
    bool? guideIncluded,
    String? mealsIncluded,
    String? accommodationType,
    List<String>? highlights,
    List<String>? keyAttractions,
    List<String>? gallery,
    String? videoUrl,
    bool? hasGroupChat,
    String? emergencySupportPhone,
    bool? isFeatured,
    bool? isPublic,
    List<String>? activities,
    int? maxMembers,
    int? favoriteCount,
  }) async {
    print('🟢 [TripViewModel] createTrip called');
    print('   Trip: $tripName -> $destination');
    print('   UserId: $userId');
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _createTripUsecase(
      CreateTripParams(
        tripName: tripName,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        status: status,
        description: description,
        category: category,
        media: media,
        destinationIds: destinationIds,
        userId: userId,
        // Required backend fields
        travelType: travelType,
        groupSizeMin: groupSizeMin,
        groupSizeMax: groupSizeMax,
        // Web parity fields
        budget: budget,
        distanceMin: distanceMin,
        distanceMax: distanceMax,
        distanceUnit: distanceUnit,
        durationMinHours: durationMinHours,
        durationMaxHours: durationMaxHours,
        difficultyLevel: difficultyLevel,
        fitnessLevel: fitnessLevel,
        physicalDemand: physicalDemand,
        skillLevelRequired: skillLevelRequired,
        bestSeason: bestSeason,
        bestMonths: bestMonths,
        elevationMin: elevationMin,
        elevationMax: elevationMax,
        elevationUnit: elevationUnit,
        inclusions: inclusions,
        exclusions: exclusions,
        guideIncluded: guideIncluded,
        mealsIncluded: mealsIncluded,
        accommodationType: accommodationType,
        highlights: highlights,
        keyAttractions: keyAttractions,
        gallery: gallery,
        videoUrl: videoUrl,
        hasGroupChat: hasGroupChat,
        emergencySupportPhone: emergencySupportPhone,
        isFeatured: isFeatured,
        isPublic: isPublic,
        activities: activities,
        maxMembers: maxMembers,
        favoriteCount: favoriteCount,
      ),
    );

    result.fold(
      (failure) {
        print('❌ [TripViewModel] Create trip FAILED: ${failure.message}');
        state = state.copyWith(
          status: TripStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        print('✅ [TripViewModel] Create trip SUCCESS');
        state = state.copyWith(status: TripStateStatus.created);
        getAllTrips();
      },
    );
  }

  Future<void> updateTrip({
    required String tripId,
    required String tripName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required TripStatus status,
    String? description,
    String? category,
    String? media,
    List<String>? destinationIds,
  }) async {
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _updateTripUsecase(
      UpdateTripParams(
        tripId: tripId,
        tripName: tripName,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        status: status,
        description: description,
        category: category,
        media: media,
        destinationIds: destinationIds,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: TripStateStatus.updated);
        getAllTrips();
      },
    );
  }

  Future<void> deleteTrip(String tripId) async {
    state = state.copyWith(status: TripStateStatus.loading);

    final result = await _deleteTripUsecase(DeleteTripParams(tripId: tripId));

    result.fold(
      (failure) => state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: TripStateStatus.deleted);
        getAllTrips();
      },
    );
  }

  Future<void> searchTrips(String query) async {
    state = state.copyWith(status: TripStateStatus.loading);

    try {
      final filtered = state.trips
          .where(
            (trip) =>
                trip.tripName.toLowerCase().contains(query.toLowerCase()) ||
                trip.destination.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      state = state.copyWith(status: TripStateStatus.loaded, trips: filtered);
    } catch (e) {
      state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: 'Search failed: $e',
      );
    }
  }

  Future<void> filterByDestination(String destination) async {
    state = state.copyWith(status: TripStateStatus.loading);

    try {
      final filtered = state.trips
          .where(
            (trip) =>
                trip.destination.toLowerCase() == destination.toLowerCase(),
          )
          .toList();

      state = state.copyWith(status: TripStateStatus.loaded, trips: filtered);
    } catch (e) {
      state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: 'Filter failed: $e',
      );
    }
  }

  Future<void> loadMoreTrips() async {
    // Pagination logic - will be implemented when API supports it
    // For now, just keep the current trips
  }

  Future<void> applyFilters(TripFilters filters) async {
    state = state.copyWith(
      status: TripStateStatus.loading,
      activeFilters: filters,
    );

    try {
      // Get all trips first to apply filters client-side
      // This will be optimized to server-side filtering in future
      final List<TripEntity> allTrips = state.trips;

      List<TripEntity> filteredTrips = allTrips;

      // Apply distance filter
      if (filters.minDistance != null || filters.maxDistance != null) {
        filteredTrips = filteredTrips.where((trip) {
          final distance = trip.distanceMin ?? 0;
          if (filters.minDistance != null && distance < filters.minDistance!) {
            return false;
          }
          if (filters.maxDistance != null && distance > filters.maxDistance!) {
            return false;
          }
          return true;
        }).toList();
      }

      // Apply duration filter
      if (filters.minDuration != null || filters.maxDuration != null) {
        filteredTrips = filteredTrips.where((trip) {
          final duration = trip.durationMinHours ?? 0;
          if (filters.minDuration != null && duration < filters.minDuration!) {
            return false;
          }
          if (filters.maxDuration != null && duration > filters.maxDuration!) {
            return false;
          }
          return true;
        }).toList();
      }

      // Apply difficulty filter
      if (filters.difficulty != null) {
        filteredTrips = filteredTrips
            .where((trip) => trip.difficultyLevel == filters.difficulty)
            .toList();
      }

      // Apply season filter
      if (filters.season != null) {
        filteredTrips = filteredTrips
            .where((trip) => trip.bestSeason == filters.season)
            .toList();
      }

      // Apply fitness level filter
      if (filters.fitnessLevel != null) {
        filteredTrips = filteredTrips
            .where((trip) => trip.fitnessLevel == filters.fitnessLevel)
            .toList();
      }

      // Apply activities filter
      if (filters.selectedActivities != null &&
          filters.selectedActivities!.isNotEmpty) {
        filteredTrips = filteredTrips.where((trip) {
          final tripActivities = trip.activities ?? [];
          return filters.selectedActivities!.any(
            (activity) => tripActivities.contains(activity),
          );
        }).toList();
      }

      state = state.copyWith(
        status: TripStateStatus.loaded,
        trips: filteredTrips,
      );
    } catch (e) {
      state = state.copyWith(
        status: TripStateStatus.error,
        errorMessage: 'Filter application failed: $e',
      );
    }
  }

  Future<void> clearFilters() async {
    // Reload all trips without filters
    state = state.copyWith(activeFilters: null);
    await getAllTrips();
  }

  Future<bool> sendJoinRequest({
    required String tripId,
    required String userId,
    String? message,
  }) async {
    try {
      final result = await ref.read(sendJoinRequestUsecaseProvider)(
        SendJoinRequestParams(tripId: tripId, userId: userId, message: message),
      );

      return result.fold((failure) => false, (success) => true);
    } catch (e) {
      log('Error sending join request: $e');
      return false;
    }
  }

  // ===== Itinerary Methods =====

  Future<void> loadItinerary(String tripId) async {
    state = state.copyWith(isLoadingItinerary: true, itineraryError: null);
    log('loadItinerary: Fetching itinerary for trip $tripId');

    final result = await _getTripItineraryUsecase(
      GetItineraryParams(tripId: tripId),
    );

    result.fold(
      (failure) {
        log('loadItinerary: Error - ${failure.message}');
        state = state.copyWith(
          isLoadingItinerary: false,
          itineraryError: failure.message,
        );
      },
      (itinerary) {
        log('loadItinerary: Success! Got ${itinerary.length} items');
        state = state.copyWith(
          isLoadingItinerary: false,
          itinerary: itinerary,
          itineraryError: null,
        );
      },
    );
  }

  void addItineraryItem(String tripId, ItineraryItemEntity item) {
    final updatedItinerary = List<ItineraryItemEntity>.from(state.itinerary)
      ..add(item);
    state = state.copyWith(itinerary: updatedItinerary);
  }

  void updateItineraryItem(String tripId, int index, ItineraryItemEntity item) {
    final updatedItinerary = List<ItineraryItemEntity>.from(state.itinerary);
    if (index >= 0 && index < updatedItinerary.length) {
      updatedItinerary[index] = item;
      state = state.copyWith(itinerary: updatedItinerary);
    }
  }

  void deleteItineraryItem(String tripId, int index) {
    final updatedItinerary = List<ItineraryItemEntity>.from(state.itinerary);
    if (index >= 0 && index < updatedItinerary.length) {
      updatedItinerary.removeAt(index);
      state = state.copyWith(itinerary: updatedItinerary);
    }
  }

  Future<bool> saveItinerary(String tripId) async {
    state = state.copyWith(isSavingItinerary: true, itineraryError: null);
    log(
      'saveItinerary: Saving ${state.itinerary.length} items for trip $tripId',
    );

    // Convert entities to maps
    final itineraryData = state.itinerary.map((item) {
      return {
        if (item.id.isNotEmpty) '_id': item.id,
        'day': item.day,
        'date': item.date.toIso8601String(),
        'title': item.title,
        if (item.description != null) 'description': item.description,
        if (item.location != null) 'location': item.location,
        if (item.activities != null) 'activities': item.activities,
        if (item.elevation != null) 'elevation': item.elevation,
        if (item.startTime != null)
          'startTime': item.startTime!.toIso8601String(),
        if (item.endTime != null) 'endTime': item.endTime!.toIso8601String(),
        if (item.notes != null) 'notes': item.notes,
        'isCompleted': item.isCompleted,
      };
    }).toList();

    final result = await _updateTripItineraryUsecase(
      UpdateItineraryParams(tripId: tripId, itinerary: itineraryData),
    );

    return result.fold(
      (failure) {
        log('saveItinerary: Error - ${failure.message}');
        state = state.copyWith(
          isSavingItinerary: false,
          itineraryError: failure.message,
        );
        return false;
      },
      (success) {
        log('saveItinerary: Success!');
        state = state.copyWith(isSavingItinerary: false, itineraryError: null);
        return true;
      },
    );
  }

  // ===== Checklist Methods =====

  Future<void> loadChecklist(String tripId) async {
    state = state.copyWith(isLoadingChecklist: true, checklistError: null);
    log('loadChecklist: Fetching checklist for trip $tripId');

    final result = await _getTripChecklistUsecase(
      GetChecklistParams(tripId: tripId),
    );

    result.fold(
      (failure) {
        log('loadChecklist: Error - ${failure.message}');
        state = state.copyWith(
          isLoadingChecklist: false,
          checklistError: failure.message,
        );
      },
      (checklist) {
        log('loadChecklist: Success! Got ${checklist.length} items');
        state = state.copyWith(
          isLoadingChecklist: false,
          checklist: checklist,
          checklistError: null,
        );
      },
    );
  }

  void addChecklistItem(String tripId, ChecklistItemEntity item) {
    final updatedChecklist = List<ChecklistItemEntity>.from(state.checklist)
      ..add(item);
    state = state.copyWith(checklist: updatedChecklist);
  }

  void toggleChecklistItem(String tripId, String itemId) {
    final updatedChecklist = List<ChecklistItemEntity>.from(state.checklist);
    final index = updatedChecklist.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      final item = updatedChecklist[index];
      final now = DateTime.now();
      final willComplete = !item.isCompleted;

      updatedChecklist[index] = ChecklistItemEntity(
        id: item.id,
        category: item.category,
        title: item.title,
        isCompleted: willComplete,
        priority: item.priority,
        completedAt: willComplete ? now : null,
        completedBy: willComplete ? 'current_user' : null,
        createdAt: item.createdAt,
      );

      state = state.copyWith(checklist: updatedChecklist);
    }
  }

  void deleteChecklistItem(String tripId, String itemId) {
    final updatedChecklist = List<ChecklistItemEntity>.from(state.checklist);
    updatedChecklist.removeWhere((item) => item.id == itemId);
    state = state.copyWith(checklist: updatedChecklist);
  }

  Future<bool> saveChecklist(String tripId) async {
    state = state.copyWith(isSavingChecklist: true, checklistError: null);
    log(
      'saveChecklist: Saving ${state.checklist.length} items for trip $tripId',
    );

    // Convert entities to maps
    final checklistData = state.checklist.map((item) {
      return {
        if (item.id.isNotEmpty) '_id': item.id,
        'category': item.category.name,
        'title': item.title,
        'isCompleted': item.isCompleted,
        if (item.priority != null) 'priority': item.priority!.name,
        if (item.completedAt != null)
          'completedAt': item.completedAt!.toIso8601String(),
        if (item.completedBy != null) 'completedBy': item.completedBy,
        if (item.createdAt != null)
          'createdAt': item.createdAt!.toIso8601String(),
      };
    }).toList();

    final result = await _updateTripChecklistUsecase(
      UpdateChecklistParams(tripId: tripId, checklist: checklistData),
    );

    return result.fold(
      (failure) {
        log('saveChecklist: Error - ${failure.message}');
        state = state.copyWith(
          isSavingChecklist: false,
          checklistError: failure.message,
        );
        return false;
      },
      (success) {
        log('saveChecklist: Success!');
        state = state.copyWith(isSavingChecklist: false, checklistError: null);
        return true;
      },
    );
  }
}

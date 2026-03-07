import 'package:equatable/equatable.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/entities/itinerary_item_entity.dart';
import 'package:tripmates/features/trip/domain/entities/checklist_item_entity.dart';
import 'package:tripmates/features/trip/presentation/widgets/advanced_filters_widget.dart';

enum TripStateStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

class TripState extends Equatable {
  final TripStateStatus status;
  final List<TripEntity> trips;
  final TripEntity? selectedTrip;
  final String? errorMessage;
  final TripFilters? activeFilters;
  final int currentPage;
  final bool hasMorePages;

  // Itinerary-specific fields
  final List<ItineraryItemEntity> itinerary;
  final bool isLoadingItinerary;
  final bool isSavingItinerary;
  final String? itineraryError;

  // Checklist-specific fields
  final List<ChecklistItemEntity> checklist;
  final bool isLoadingChecklist;
  final bool isSavingChecklist;
  final String? checklistError;

  const TripState({
    this.status = TripStateStatus.initial,
    this.trips = const [],
    this.selectedTrip,
    this.errorMessage,
    this.activeFilters,
    this.checklist = const [],
    this.isLoadingChecklist = false,
    this.isSavingChecklist = false,
    this.checklistError,
    this.currentPage = 0,
    this.hasMorePages = true,
    this.itinerary = const [],
    this.isLoadingItinerary = false,
    this.isSavingItinerary = false,
    this.itineraryError,
  });

  TripState copyWith({
    TripStateStatus? status,
    List<TripEntity>? trips,
    TripEntity? selectedTrip,
    String? errorMessage,
    TripFilters? activeFilters,
    int? currentPage,
    bool? hasMorePages,
    List<ItineraryItemEntity>? itinerary,
    bool? isLoadingItinerary,
    bool? isSavingItinerary,
    String? itineraryError,
    List<ChecklistItemEntity>? checklist,
    bool? isLoadingChecklist,
    bool? isSavingChecklist,
    String? checklistError,
  }) {
    return TripState(
      status: status ?? this.status,
      trips: trips ?? this.trips,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      errorMessage: errorMessage ?? this.errorMessage,
      activeFilters: activeFilters ?? this.activeFilters,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      itinerary: itinerary ?? this.itinerary,
      isLoadingItinerary: isLoadingItinerary ?? this.isLoadingItinerary,
      isSavingItinerary: isSavingItinerary ?? this.isSavingItinerary,
      itineraryError: itineraryError ?? this.itineraryError,
      checklist: checklist ?? this.checklist,
      isLoadingChecklist: isLoadingChecklist ?? this.isLoadingChecklist,
      isSavingChecklist: isSavingChecklist ?? this.isSavingChecklist,
      checklistError: checklistError ?? this.checklistError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    trips,
    selectedTrip,
    errorMessage,
    activeFilters,
    currentPage,
    hasMorePages,
    itinerary,
    isLoadingItinerary,
    isSavingItinerary,
    itineraryError,
    checklist,
    isLoadingChecklist,
    isSavingChecklist,
    checklistError,
  ];
}

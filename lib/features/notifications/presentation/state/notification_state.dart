import 'package:equatable/equatable.dart';
import 'package:tripmates/features/notifications/domain/entities/notification_entity.dart';

/// State for notifications feature
class NotificationState extends Equatable {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String?
  selectedFilter; // null, 'message', 'trip', 'partner_request', etc.
  final int currentPage;
  final bool hasMoreData;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.selectedFilter,
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  @override
  List<Object?> get props => [
    notifications,
    unreadCount,
    isLoading,
    isLoadingMore,
    error,
    selectedFilter,
    currentPage,
    hasMoreData,
  ];

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? selectedFilter,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }

  /// Filter notifications by type
  List<NotificationEntity> get filteredNotifications {
    if (selectedFilter == null) return notifications;
    return notifications.where((n) => n.type == selectedFilter).toList();
  }
}

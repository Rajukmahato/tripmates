import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:tripmates/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:tripmates/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:tripmates/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:tripmates/features/notifications/domain/usecases/mark_all_as_read_usecase.dart';
import 'package:tripmates/features/notifications/domain/usecases/mark_as_read_usecase.dart';
import 'package:tripmates/features/notifications/presentation/state/notification_state.dart';

/// ViewModel for notifications feature
class NotificationViewmodel extends Notifier<NotificationState> {
  late final GetNotificationsUseCase _getNotificationsUseCase;
  late final GetUnreadCountUseCase _getUnreadCountUseCase;
  late final MarkAsReadUseCase _markAsReadUseCase;
  late final MarkAllAsReadUseCase _markAllAsReadUseCase;
  late final DeleteNotificationUseCase _deleteNotificationUseCase;

  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(seconds: 30);
  bool _isFetching = false;

  @override
  NotificationState build() {
    final repository = ref.read(notificationRepositoryProvider);
    _getNotificationsUseCase = GetNotificationsUseCase(repository);
    _getUnreadCountUseCase = GetUnreadCountUseCase(repository);
    _markAsReadUseCase = MarkAsReadUseCase(repository);
    _markAllAsReadUseCase = MarkAllAsReadUseCase(repository);
    _deleteNotificationUseCase = DeleteNotificationUseCase(repository);
    return const NotificationState();
  }

  /// Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    // Prevent duplicate simultaneous requests
    if (_isFetching) return;

    // Use cache if available and not forcing refresh
    if (!refresh && _lastFetchTime != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
      if (timeSinceLastFetch < _cacheDuration) {
        return;
      }
    }

    if (refresh) {
      _lastFetchTime = null;
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMoreData: true,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return; // Prevent duplicate requests
    }

    _isFetching = true;

    final result = await _getNotificationsUseCase(
      page: refresh ? 1 : state.currentPage,
      limit: 20,
      type: state.selectedFilter,
    );

    result.fold(
      (failure) {
        _isFetching = false;
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        );
      },
      (notifications) {
        _isFetching = false;
        _lastFetchTime = DateTime.now();
        final updatedNotifications = refresh
            ? notifications
            : [...state.notifications, ...notifications];

        state = state.copyWith(
          notifications: updatedNotifications,
          isLoading: false,
          isLoadingMore: false,
          error: null,
          currentPage: refresh ? 2 : state.currentPage + 1,
          hasMoreData: notifications.length >= 20,
        );

        // Also update unread count
        _updateUnreadCount();
      },
    );
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (!state.hasMoreData || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);
    await loadNotifications();
  }

  /// Update unread count
  Future<void> _updateUnreadCount() async {
    final result = await _getUnreadCountUseCase();
    result.fold(
      (failure) {
        // Silently fail, don't update UI
      },
      (count) {
        state = state.copyWith(unreadCount: count);
      },
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await _markAsReadUseCase(notificationId);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Update local state
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }
          return notification;
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        );
      },
    );
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final result = await _markAllAsReadUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Update local state
        final updatedNotifications = state.notifications.map((notification) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      },
    );
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final result = await _deleteNotificationUseCase(notificationId);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Remove from local state
        final updatedNotifications = state.notifications
            .where((notification) => notification.id != notificationId)
            .toList();

        // Decrease unread count if it was unread
        final wasUnread = state.notifications
            .firstWhere((n) => n.id == notificationId)
            .isRead;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: wasUnread && state.unreadCount > 0
              ? state.unreadCount - 1
              : state.unreadCount,
        );
      },
    );
  }

  /// Set filter
  void setFilter(String? filter) {
    state = state.copyWith(selectedFilter: filter);
    loadNotifications(refresh: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state (for logout)
  void resetState() {
    state = const NotificationState();
  }
}

/// Riverpod provider for NotificationViewmodel
final notificationViewmodelProvider =
    NotifierProvider<NotificationViewmodel, NotificationState>(
      NotificationViewmodel.new,
    );

/// Separate provider for unread count (for badge updates)
final unreadCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationViewmodelProvider);
  return notificationState.unreadCount;
});

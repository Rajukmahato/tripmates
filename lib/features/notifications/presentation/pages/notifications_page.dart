import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/notifications/presentation/state/notification_state.dart';
import 'package:tripmates/features/notifications/presentation/viewmodel/notification_viewmodel.dart';
import 'package:tripmates/features/notifications/presentation/widgets/notification_item.dart';
import 'package:tripmates/features/partner_requests/presentation/pages/partner_requests_page.dart';

/// Notifications page showing all user notifications
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load notifications on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationViewmodelProvider.notifier)
          .loadNotifications(refresh: true);
    });

    // Setup pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        ref
            .read(notificationViewmodelProvider.notifier)
            .loadMoreNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationViewmodelProvider);
    final notificationViewmodel = ref.read(
      notificationViewmodelProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Filter button
          PopupMenuButton<String?>(
            icon: Icon(
              notificationState.selectedFilter != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onSelected: (filter) {
              notificationViewmodel.setFilter(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(value: 'message', child: Text('Messages')),
              const PopupMenuItem(value: 'trip', child: Text('Trips')),
              const PopupMenuItem(
                value: 'partner_request',
                child: Text('Partner Requests'),
              ),
              const PopupMenuItem(value: 'review', child: Text('Reviews')),
            ],
          ),
          // Mark all as read button
          if (notificationState.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () {
                notificationViewmodel.markAllAsRead();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await notificationViewmodel.loadNotifications(refresh: true);
        },
        child: _buildBody(notificationState, notificationViewmodel),
      ),
    );
  }

  Widget _buildBody(NotificationState state, NotificationViewmodel viewmodel) {
    // Loading state
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.error != null && state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewmodel.loadNotifications(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see notifications here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // List of notifications
    return ListView.builder(
      controller: _scrollController,
      itemCount:
          state.filteredNotifications.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at bottom
        if (index == state.filteredNotifications.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notification = state.filteredNotifications[index];
        return NotificationItem(
          notification: notification,
          onTap: () {
            // Mark as read when tapped
            if (!notification.isRead) {
              viewmodel.markAsRead(notification.id);
            }
            // Handle navigation based on type
            _handleNotificationTap(notification);
          },
          onDelete: () {
            viewmodel.deleteNotification(notification.id);
          },
        );
      },
    );
  }

  void _handleNotificationTap(notification) {
    // Navigate to appropriate screen based on notification type
    switch (notification.type) {
      case 'message':
        // Navigate to chat/conversation
        if (notification.data?['conversationId'] != null) {
          // Pending enhancement: load conversation and navigate
          // For now, show snackbar as ConversationDetailPage needs ConversationEntity
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening conversation...')),
          );
        }
        break;

      case 'trip':
        // Navigate to trip details using tripId
        // Since notification doesn't have full trip data, we can't navigate directly
        // This would require loading the trip first from the repository
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading trip details...')),
        );
        // Pending enhancement: implement proper trip loading from notification tripId
        break;

      case 'partner_request':
        // Navigate to partner requests
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PartnerRequestsPage()),
        );
        break;

      case 'review':
        // Navigate to reviews
        if (notification.data?['tripId'] != null) {
          // Pending enhancement: navigate to reviews with tripId parameter
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Opening review...')));
        }
        break;

      case 'admin':
        // Show admin message or navigate to settings
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title),
            content: Text(notification.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;

      default:
        // For unknown types, show a generic message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification opened')));
    }
  }
}

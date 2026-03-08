import 'dart:developer' show log;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/entities/trip_member_entity.dart';
import 'package:tripmates/features/trip/domain/entities/itinerary_item_entity.dart';
import 'package:tripmates/features/trip/domain/entities/checklist_item_entity.dart';
import 'package:tripmates/features/trip/presentation/view_model/trip_viewmodel.dart';
import 'package:tripmates/features/trip/presentation/widgets/checklist_item_form.dart';
import 'package:tripmates/features/chat/presentation/view_model/chat_viewmodel.dart';
import 'package:tripmates/features/chat/presentation/pages/conversation_detail_page.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/features/location/presentation/viewmodel/location_viewmodel.dart';
import 'package:tripmates/features/location/presentation/pages/location_sharing_page.dart';
import 'package:tripmates/features/location/presentation/widgets/location_controls_widget.dart';

class EnhancedTripDetailPage extends ConsumerStatefulWidget {
  final TripEntity trip;

  const EnhancedTripDetailPage({super.key, required this.trip});

  @override
  ConsumerState<EnhancedTripDetailPage> createState() =>
      _EnhancedTripDetailPageState();
}

class _EnhancedTripDetailPageState extends ConsumerState<EnhancedTripDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ChecklistCategory? _selectedChecklistCategory;
  String _checklistStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 2 && widget.trip.tripId != null) {
        ref
            .read(tripViewModelProvider.notifier)
            .loadItinerary(widget.trip.tripId!);
      } else if (_tabController.index == 3 && widget.trip.tripId != null) {
        ref
            .read(tripViewModelProvider.notifier)
            .loadChecklist(widget.trip.tripId!);
      } else if (_tabController.index == 4 && widget.trip.tripId != null) {
        ref
            .read(locationViewModelProvider.notifier)
            .loadTripLocations(widget.trip.tripId!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final daysUntil = trip.startDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(trip),

          // Trip Header Info
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status and Days Until
                        Row(
                          children: [
                            _buildStatusBadge(trip.status, trip),
                            const SizedBox(width: 12),
                            if (daysUntil > 0 && !_isTripExpired(trip))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(26),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'In $daysUntil days',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          trip.tripName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Quick Info Cards
                        _buildQuickInfoCards(trip, dateFormat),

                        const SizedBox(height: 16),

                        // Action Buttons
                        _buildActionButtons(trip),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.textTertiary.withAlpha(26),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: context.textTertiary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Members'),
                        Tab(text: 'Itinerary'),
                        Tab(text: 'Checklist'),
                        Tab(text: 'Location'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(trip),
                _buildMembersTab(trip),
                _buildItineraryTab(trip),
                _buildChecklistTab(trip),
                _buildLocationTab(trip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(TripEntity trip) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black54,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: () => _shareTrip(widget.trip),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: trip.media != null && trip.media!.isNotEmpty
            ? (trip.media!.startsWith('http')
                  ? Image.network(trip.media!, fit: BoxFit.cover)
                  : Image.file(File(trip.media!), fit: BoxFit.cover))
            : Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: const Center(
                  child: Icon(
                    Icons.luggage_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  /// Check if trip is expired based on end date (regardless of stored status)
  bool _isTripExpired(TripEntity trip) {
    final now = DateTime.now();
    final tripEndDate = DateTime(
      trip.endDate.year,
      trip.endDate.month,
      trip.endDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    return tripEndDate.isBefore(today);
  }

  /// Check if trip start date is in the future
  bool _isTripPlanned(TripEntity trip) {
    final now = DateTime.now();
    final tripStartDate = DateTime(
      trip.startDate.year,
      trip.startDate.month,
      trip.startDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    return tripStartDate.isAfter(today);
  }

  Widget _buildStatusBadge(TripStatus status, TripEntity trip) {
    final userSessionService = ref.read(userSessionServiceProvider);
    final currentUserId = userSessionService.getCurrentUserId() ?? '';
    final isMember =
        trip.members?.any((m) => m.userId == currentUserId) ?? false;

    String label;
    Gradient gradient;

    // Check if trip is expired based on dates
    final isExpired = _isTripExpired(trip);

    if (isExpired) {
      label = 'EXPIRED';
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey[600]!, Colors.grey[800]!],
      );
    } else if (_isTripPlanned(trip)) {
      // Trip is planned (future start date)
      if (isMember) {
        label = 'PLANNED';
        gradient = AppColors.primaryGradient;
      } else {
        label = 'UPCOMING';
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        );
      }
    } else {
      switch (status) {
        case TripStatus.planned:
          label = 'UPCOMING';
          gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[400]!, Colors.blue[600]!],
          );
          break;
        case TripStatus.ongoing:
          label = 'ONGOING';
          gradient = AppColors.lostGradient;
          break;
        case TripStatus.completed:
          label = 'EXPIRED';
          gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[600]!, Colors.grey[800]!],
          );
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickInfoCards(TripEntity trip, DateFormat dateFormat) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.location_on_rounded,
            title: 'Destination',
            value: trip.destination,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.calendar_today_rounded,
            title: 'Duration',
            value:
                '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: context.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TripEntity trip) {
    final userSessionService = ref.read(userSessionServiceProvider);
    final currentUserId = userSessionService.getCurrentUserId() ?? '';

    // Check if current user is the trip creator
    final isCreator = trip.createdBy == currentUserId;

    // Check if current user is already a member
    final isMember =
        trip.members?.any((m) => m.userId == currentUserId) ?? false;

    // Check if trip is expired (based on dates or status)
    final isExpired =
        _isTripExpired(trip) || trip.status == TripStatus.completed;

    // Don't show join/leave button if user is creator or already member or if trip is expired
    final shouldShowJoinButton = !isCreator && !isMember && !isExpired;

    return Row(
      children: [
        if (shouldShowJoinButton)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleJoinOrLeavTrip(trip, isMember),
              icon: const Icon(Icons.person_add),
              label: const Text('Join Trip'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (shouldShowJoinButton)
          const SizedBox(width: 12)
        else
          const SizedBox(width: 0),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isExpired ? [] : AppColors.buttonShadow,
            ),
            child: ElevatedButton.icon(
              onPressed: isExpired ? null : () => _openGroupChat(trip),
              icon: Icon(
                Icons.message_rounded,
                color: isExpired ? Colors.grey : Colors.white,
              ),
              label: Text(
                'Group Chat',
                style: TextStyle(color: isExpired ? Colors.grey : Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleJoinOrLeavTrip(TripEntity trip, bool isMember) async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId();

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      }
    } else if (isMember) {
      // Leave trip
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Successfully left trip!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Join trip
      final tripNotifier = ref.read(tripViewModelProvider.notifier);
      final chatNotifier = ref.read(chatViewModelProvider.notifier);

      final success = await tripNotifier.sendJoinRequest(
        tripId: trip.tripId ?? '',
        userId: userId,
      );

      if (success && mounted) {
        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Successfully joined trip!')),
        );

        // Add user to group chat for this trip if groupChatId exists
        if (trip.groupChatId != null) {
          try {
            // Add user to the group chat
            await chatNotifier.addParticipant(trip.groupChatId!, userId);

            // Reload conversations to show the new group chat
            await chatNotifier.loadConversations(userId);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Joined trip but group chat sync pending'),
                ),
              );
            }
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('❌ Failed to join trip')));
      }
    }
  }

  Future<void> _openGroupChat(TripEntity trip) async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final currentUserId = userSessionService.getCurrentUserId();

    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      }
      return;
    }

    // Web frontend expects groupChatId to exist before opening group chat
    if (trip.groupChatId == null || trip.groupChatId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group chat not available. Please refresh the trip.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final chatNotifier = ref.read(chatViewModelProvider.notifier);

      log(
        '🔍 [GroupChat] Opening group chat for trip="${trip.tripName}", tripId="${trip.tripId}", groupChatId="${trip.groupChatId}"',
      );

      ConversationEntity? groupConversation = await chatNotifier
          .loadGroupChatByGroupId(trip.groupChatId!);

      if (groupConversation == null && trip.tripId != null) {
        log('🔁 [GroupChat] Falling back to tripId lookup');
        groupConversation = await chatNotifier.loadGroupChatByTripId(
          trip.tripId!,
        );
      }

      if (groupConversation == null) {
        throw Exception(
          'Group chat not found for groupChatId="${trip.groupChatId}"',
        );
      }

      if (mounted) {
        final resolvedConversation = groupConversation;
        chatNotifier.selectConversation(resolvedConversation);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ConversationDetailPage(conversation: resolvedConversation),
          ),
        );
      }
    } catch (e) {
      log('❌ [GroupChat] Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error opening group chat:\n$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _shareTrip(TripEntity trip) {
    final tripName = trip.tripName;
    final destination = trip.destination;
    final message =
        'Check out "$tripName" - A trip to $destination. Join me on TripMates!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: $message'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openOneOnOneChat(TripMemberEntity member) async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final currentUserId = userSessionService.getCurrentUserId();

    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      }
      return;
    }

    final chatNotifier = ref.read(chatViewModelProvider.notifier);
    final success = await chatNotifier.createOneOnOneConversation(
      currentUserId,
      member.userId,
    );

    if (success && mounted) {
      // Reload conversations
      await chatNotifier.loadConversations(currentUserId);
      final chatState = ref.read(chatViewModelProvider);

      // Find the conversation
      try {
        final conversation = chatState.conversations.firstWhere(
          (conv) =>
              (conv.otherUserName == member.fullName ||
                  conv.participantIds.contains(member.userId)) &&
              conv.type == ConversationType.oneOnOne,
        );

        if (mounted) {
          chatNotifier.selectConversation(conversation);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ConversationDetailPage(conversation: conversation),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat with ${member.fullName}')),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create chat')));
    }
  }

  Future<void> _toggleChecklistItem(
    TripEntity trip,
    ChecklistItemEntity item,
  ) async {
    if (trip.tripId == null) return;

    final notifier = ref.read(tripViewModelProvider.notifier);
    notifier.toggleChecklistItem(trip.tripId!, item.id);
    final success = await notifier.saveChecklist(trip.tripId!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (!item.isCompleted ? '✅ Item completed' : '↩️ Item unchecked')
              : 'Failed to update checklist item',
        ),
      ),
    );
  }

  Widget _buildOverviewTab(TripEntity trip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSection(
            title: 'About This Trip',
            child: Text(
              trip.description ?? 'No description provided.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: context.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Budget & Group Size
          _buildSection(
            title: 'Trip Details',
            child: Column(
              children: [
                _buildDetailRow(
                  'Budget',
                  trip.budget != null
                      ? 'NPR ${trip.budget!.toStringAsFixed(0)}'
                      : 'Not specified',
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Group Size',
                  '${trip.groupSizeMin ?? 1} - ${trip.groupSizeMax ?? 0} people',
                ),
                if (trip.travelType != null) ...[
                  const Divider(height: 24),
                  _buildDetailRow('Travel Type', trip.travelType!),
                ],
                if (trip.difficultyLevel != null) ...[
                  const Divider(height: 24),
                  _buildDetailRow('Difficulty', trip.difficultyLevel!),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Creator Info
          if (trip.createdByName != null)
            _buildSection(
              title: 'Created By',
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: trip.createdByAvatar != null
                        ? NetworkImage(trip.createdByAvatar!)
                        : null,
                    backgroundColor: AppColors.primary.withAlpha(51),
                    child: trip.createdByAvatar == null
                        ? Text(
                            trip.createdByName![0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.createdByName!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Trip Organizer',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Rating
          if (trip.averageRating != null && trip.reviewCount != null)
            _buildSection(
              title: 'Rating',
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    trip.averageRating!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${trip.reviewCount} reviews)',
                    style: TextStyle(fontSize: 14, color: context.textTertiary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(TripEntity trip) {
    final members = trip.members ?? [];

    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: context.textTertiary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No members yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to join this trip!',
              style: TextStyle(fontSize: 14, color: context.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(TripMemberEntity member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: member.profilePicture != null
                ? NetworkImage(member.profilePicture!)
                : null,
            backgroundColor: AppColors.primary.withAlpha(51),
            child: member.profilePicture == null
                ? Text(
                    member.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    if (member.role == 'creator')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Organizer',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.email,
                  style: TextStyle(fontSize: 14, color: context.textTertiary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.message_rounded, color: AppColors.primary),
            onPressed: () => _openOneOnOneChat(member),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab(TripEntity trip) {
    final tripState = ref.watch(tripViewModelProvider);
    final itinerary = tripState.itinerary;

    // Loading state
    if (tripState.isLoadingItinerary) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (tripState.itineraryError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading itinerary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tripState.itineraryError!,
              style: TextStyle(fontSize: 14, color: context.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (trip.tripId != null) {
                  ref
                      .read(tripViewModelProvider.notifier)
                      .loadItinerary(trip.tripId!);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (itinerary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_rounded,
              size: 80,
              color: context.textTertiary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No itinerary yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plan your trip activities',
              style: TextStyle(fontSize: 14, color: context.textTertiary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _addItineraryItem(trip),
              icon: const Icon(Icons.add),
              label: const Text('Add First Activity'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group by day
    final groupedByDay = <int, List<ItineraryItemEntity>>{};
    for (final item in itinerary) {
      groupedByDay.putIfAbsent(item.day, () => []).add(item);
    }
    final sortedDays = groupedByDay.keys.toList()..sort();

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          itemCount: sortedDays.length,
          itemBuilder: (context, dayIndex) {
            final day = sortedDays[dayIndex];
            final dayItems = groupedByDay[day]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Header
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Day $day',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Day Items
                ...dayItems.asMap().entries.map((entry) {
                  final itemIndex = itinerary.indexOf(entry.value);
                  return _buildItineraryCard(entry.value, itemIndex, trip);
                }),
              ],
            );
          },
        ),

        // FAB to add items
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () => _addItineraryItem(trip),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _addItineraryItem(TripEntity trip) {
    showDialog(
      context: context,
      builder: (context) => _ItineraryItemDialog(
        trip: trip,
        onSave: (item) {
          if (trip.tripId != null) {
            ref
                .read(tripViewModelProvider.notifier)
                .addItineraryItem(trip.tripId!, item);
            ref
                .read(tripViewModelProvider.notifier)
                .saveItinerary(trip.tripId!);
          }
        },
      ),
    );
  }

  void _editItineraryItem(
    TripEntity trip,
    int index,
    ItineraryItemEntity item,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ItineraryItemDialog(
        trip: trip,
        item: item,
        onSave: (updatedItem) {
          if (trip.tripId != null) {
            ref
                .read(tripViewModelProvider.notifier)
                .updateItineraryItem(trip.tripId!, index, updatedItem);
            ref
                .read(tripViewModelProvider.notifier)
                .saveItinerary(trip.tripId!);
          }
        },
      ),
    );
  }

  void _deleteItineraryItem(TripEntity trip, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (trip.tripId != null) {
                ref
                    .read(tripViewModelProvider.notifier)
                    .deleteItineraryItem(trip.tripId!, index);
                ref
                    .read(tripViewModelProvider.notifier)
                    .saveItinerary(trip.tripId!);
              }
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryCard(
    ItineraryItemEntity item,
    int index,
    TripEntity trip,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.softShadow,
        border: item.isCompleted
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: item.isCompleted
                            ? AppColors.foundGradient
                            : AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: item.isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: context.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(item.date),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textTertiary,
                                ),
                              ),
                              if (item.startTime != null) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: context.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeFormat.format(item.startTime!),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (item.location != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: context.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.location!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.textTertiary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (item.elevation != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.terrain,
                                  size: 14,
                                  color: context.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.elevation}m elevation',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (item.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              item.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                          if (item.activities != null &&
                              item.activities!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: item.activities!.map((activity) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(26),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    activity,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editItineraryItem(trip, index, item);
                        } else if (value == 'delete') {
                          _deleteItineraryItem(trip, index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistTab(TripEntity trip) {
    final tripState = ref.watch(tripViewModelProvider);
    final checklist = tripState.checklist;

    if (tripState.isLoadingChecklist) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tripState.checklistError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading checklist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tripState.checklistError!,
              style: TextStyle(fontSize: 14, color: context.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (trip.tripId != null) {
                  ref
                      .read(tripViewModelProvider.notifier)
                      .loadChecklist(trip.tripId!);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (checklist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 80,
              color: context.textTertiary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No checklist items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to prepare for the trip',
              style: TextStyle(fontSize: 14, color: context.textTertiary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _addChecklistItem(trip),
              icon: const Icon(Icons.add),
              label: const Text('Add First Item'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _addDefaultChecklistTemplate(trip),
              icon: const Icon(Icons.auto_fix_high_rounded),
              label: const Text('Use Default Template'),
            ),
          ],
        ),
      );
    }

    final completedCount = checklist.where((item) => item.isCompleted).length;
    final completionRate = checklist.isEmpty
        ? 0.0
        : completedCount / checklist.length;

    final filteredChecklist = checklist.where((item) {
      final categoryMatches =
          _selectedChecklistCategory == null ||
          item.category == _selectedChecklistCategory;
      final statusMatches =
          _checklistStatusFilter == 'all' ||
          (_checklistStatusFilter == 'completed' && item.isCompleted) ||
          (_checklistStatusFilter == 'pending' && !item.isCompleted);
      return categoryMatches && statusMatches;
    }).toList();

    final grouped = <ChecklistCategory, List<ChecklistItemEntity>>{};
    for (final category in ChecklistCategory.values) {
      final items = filteredChecklist
          .where((item) => item.category == category)
          .toList();
      if (items.isNotEmpty) {
        grouped[category] = items;
      }
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: context.softShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount / ${checklist.length} completed',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(completionRate * 100).toStringAsFixed(0)}% complete',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: completionRate,
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ChecklistCategory?>(
                    initialValue: _selectedChecklistCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: context.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<ChecklistCategory?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...ChecklistCategory.values.map(
                        (category) => DropdownMenuItem<ChecklistCategory?>(
                          value: category,
                          child: Text(_categoryLabel(category)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedChecklistCategory = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _checklistStatusFilter,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      filled: true,
                      fillColor: context.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Expired'),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _checklistStatusFilter = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filteredChecklist.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No items match current filters',
                  style: TextStyle(fontSize: 14, color: context.textTertiary),
                ),
              )
            else
              ...ChecklistCategory.values
                  .where((category) => grouped.containsKey(category))
                  .map((category) {
                    final categoryItems = grouped[category]!;
                    final categoryCompleted = categoryItems
                        .where((item) => item.isCompleted)
                        .length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 8),
                          child: Row(
                            children: [
                              Icon(
                                _categoryIcon(category),
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _categoryLabel(category),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$categoryCompleted/${categoryItems.length}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...categoryItems.map(
                          (item) => _buildChecklistItem(trip, item),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () => _addChecklistItem(trip),
            child: const Icon(Icons.add),
          ),
        ),
        if (tripState.isSavingChecklist)
          Positioned.fill(
            child: Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildChecklistItem(TripEntity trip, ChecklistItemEntity item) {
    return Dismissible(
      key: ValueKey('checklist_${item.id}_${item.title}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteChecklistItem(trip, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: context.softShadow,
        ),
        child: CheckboxListTile(
          value: item.isCompleted,
          onChanged: (_) => _toggleChecklistItem(trip, item),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 15,
              color: context.textPrimary,
              decoration: item.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: item.priority != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Priority: ${_priorityLabel(item.priority!)}',
                    style: TextStyle(fontSize: 12, color: context.textTertiary),
                  ),
                )
              : null,
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }

  Future<void> _addChecklistItem(TripEntity trip) async {
    final addedItem = await showDialog<ChecklistItemEntity>(
      context: context,
      builder: (context) => const ChecklistItemFormDialog(),
    );

    if (addedItem != null && trip.tripId != null) {
      final notifier = ref.read(tripViewModelProvider.notifier);
      notifier.addChecklistItem(trip.tripId!, addedItem);
      await notifier.saveChecklist(trip.tripId!);
    }
  }

  Future<void> _deleteChecklistItem(
    TripEntity trip,
    ChecklistItemEntity item,
  ) async {
    if (trip.tripId == null) return;

    final notifier = ref.read(tripViewModelProvider.notifier);
    notifier.deleteChecklistItem(trip.tripId!, item.id);
    await notifier.saveChecklist(trip.tripId!);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Checklist item deleted')));
  }

  Future<void> _addDefaultChecklistTemplate(TripEntity trip) async {
    if (trip.tripId == null) return;

    final templateItems = _buildDefaultTemplateItems(trip);
    final notifier = ref.read(tripViewModelProvider.notifier);
    for (final item in templateItems) {
      notifier.addChecklistItem(trip.tripId!, item);
    }
    await notifier.saveChecklist(trip.tripId!);
  }

  List<ChecklistItemEntity> _buildDefaultTemplateItems(TripEntity trip) {
    final travelType = (trip.travelType ?? '').toLowerCase();
    final now = DateTime.now();

    List<Map<String, dynamic>> template;
    if (travelType.contains('hiking') || travelType.contains('trek')) {
      template = [
        {'title': 'ID/Passport', 'category': ChecklistCategory.documents},
        {'title': 'Backpack', 'category': ChecklistCategory.packing},
        {'title': 'Hiking boots', 'category': ChecklistCategory.packing},
        {'title': 'First aid kit', 'category': ChecklistCategory.health},
        {
          'title': 'Emergency contacts saved',
          'category': ChecklistCategory.preparation,
        },
      ];
    } else if (travelType.contains('beach')) {
      template = [
        {'title': 'ID/Passport', 'category': ChecklistCategory.documents},
        {'title': 'Swimwear', 'category': ChecklistCategory.packing},
        {'title': 'Sunscreen', 'category': ChecklistCategory.health},
        {'title': 'Hotel confirmation', 'category': ChecklistCategory.booking},
        {
          'title': 'Local transport plan',
          'category': ChecklistCategory.preparation,
        },
      ];
    } else {
      template = [
        {'title': 'ID/Passport', 'category': ChecklistCategory.documents},
        {'title': 'Flight/Bus tickets', 'category': ChecklistCategory.booking},
        {
          'title': 'Accommodation confirmation',
          'category': ChecklistCategory.booking,
        },
        {
          'title': 'Essential clothes packed',
          'category': ChecklistCategory.packing,
        },
        {'title': 'Medicines packed', 'category': ChecklistCategory.health},
      ];
    }

    return template.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return ChecklistItemEntity(
        id: 'template_${now.microsecondsSinceEpoch}_$index',
        category: item['category'] as ChecklistCategory,
        title: item['title'] as String,
        isCompleted: false,
        createdAt: now,
      );
    }).toList();
  }

  String _categoryLabel(ChecklistCategory category) {
    switch (category) {
      case ChecklistCategory.documents:
        return 'Documents';
      case ChecklistCategory.packing:
        return 'Packing';
      case ChecklistCategory.health:
        return 'Health';
      case ChecklistCategory.booking:
        return 'Booking';
      case ChecklistCategory.preparation:
        return 'Preparation';
    }
  }

  IconData _categoryIcon(ChecklistCategory category) {
    switch (category) {
      case ChecklistCategory.documents:
        return Icons.badge_outlined;
      case ChecklistCategory.packing:
        return Icons.luggage_outlined;
      case ChecklistCategory.health:
        return Icons.health_and_safety_outlined;
      case ChecklistCategory.booking:
        return Icons.confirmation_number_outlined;
      case ChecklistCategory.preparation:
        return Icons.task_alt_outlined;
    }
  }

  String _priorityLabel(ChecklistPriority priority) {
    switch (priority) {
      case ChecklistPriority.low:
        return 'Low';
      case ChecklistPriority.medium:
        return 'Medium';
      case ChecklistPriority.high:
        return 'High';
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildLocationTab(TripEntity trip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          LocationControlsWidget(
            tripId: trip.tripId ?? '',
            onSharePressed: trip.tripId != null
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LocationSharingPage(
                          tripId: trip.tripId!,
                          tripName: trip.tripName,
                        ),
                      ),
                    );
                  }
                : null,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Real-time location sharing enables all trip members to track each other on a map. '
                      'Your location is only shared when you explicitly enable it and is kept private to trip members only.',
                      style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15, color: context.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Itinerary Item Dialog
class _ItineraryItemDialog extends StatefulWidget {
  final TripEntity trip;
  final ItineraryItemEntity? item;
  final Function(ItineraryItemEntity) onSave;

  const _ItineraryItemDialog({
    required this.trip,
    this.item,
    required this.onSave,
  });

  @override
  State<_ItineraryItemDialog> createState() => _ItineraryItemDialogState();
}

class _ItineraryItemDialogState extends State<_ItineraryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _elevationController;
  late TextEditingController _notesController;
  late TextEditingController _activitiesController;
  late int _selectedDay;
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.item?.location ?? '',
    );
    _elevationController = TextEditingController(
      text: widget.item?.elevation?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _activitiesController = TextEditingController(
      text: widget.item?.activities?.join(', ') ?? '',
    );
    _selectedDay = widget.item?.day ?? 1;
    _selectedDate = widget.item?.date ?? widget.trip.startDate;
    _isCompleted = widget.item?.isCompleted ?? false;

    if (widget.item?.startTime != null) {
      _startTime = TimeOfDay.fromDateTime(widget.item!.startTime!);
    }
    if (widget.item?.endTime != null) {
      _endTime = TimeOfDay.fromDateTime(widget.item!.endTime!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _elevationController.dispose();
    _notesController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripDuration =
        widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_note, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.item == null ? 'Add Activity' : 'Edit Activity',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day selector
                      DropdownButtonFormField<int>(
                        initialValue: _selectedDay,
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(tripDuration, (index) {
                          final day = index + 1;
                          return DropdownMenuItem(
                            value: day,
                            child: Text('Day $day'),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDay = value;
                              _selectedDate = widget.trip.startDate.add(
                                Duration(days: value - 1),
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Range
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _startTime ?? TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setState(() => _startTime = time);
                                }
                              },
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                _startTime != null
                                    ? _startTime!.format(context)
                                    : 'Start Time',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _endTime ?? TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setState(() => _endTime = time);
                                }
                              },
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                _endTime != null
                                    ? _endTime!.format(context)
                                    : 'End Time',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Elevation
                      TextFormField(
                        controller: _elevationController,
                        decoration: const InputDecoration(
                          labelText: 'Elevation (meters)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.terrain),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Activities (comma separated)
                      TextFormField(
                        controller: _activitiesController,
                        decoration: const InputDecoration(
                          labelText: 'Activities (comma separated)',
                          border: OutlineInputBorder(),
                          hintText: 'Hiking, Photography, Swimming',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Completed checkbox
                      CheckboxListTile(
                        value: _isCompleted,
                        onChanged: (value) {
                          setState(() => _isCompleted = value ?? false);
                        },
                        title: const Text('Mark as completed'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    // Parse activities
    List<String>? activities;
    if (_activitiesController.text.trim().isNotEmpty) {
      activities = _activitiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Parse elevation
    double? elevation;
    if (_elevationController.text.trim().isNotEmpty) {
      elevation = double.tryParse(_elevationController.text.trim());
    }

    // Convert TimeOfDay to DateTime
    DateTime? startTime;
    if (_startTime != null) {
      startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }

    DateTime? endTime;
    if (_endTime != null) {
      endTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    final item = ItineraryItemEntity(
      id: widget.item?.id ?? '',
      day: _selectedDay,
      date: _selectedDate,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      activities: activities,
      elevation: elevation,
      startTime: startTime,
      endTime: endTime,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      isCompleted: _isCompleted,
    );

    widget.onSave(item);
    Navigator.pop(context);
  }
}

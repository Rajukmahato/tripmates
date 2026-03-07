import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/presentation/view_model/chat_viewmodel.dart';
import 'package:tripmates/features/chat/presentation/state/chat_state.dart';
import 'package:tripmates/features/chat/presentation/pages/conversation_detail_page.dart';
import 'package:tripmates/features/chat/presentation/widgets/conversation_item.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() =>
      _ConversationListPageState();
}

class _ConversationListPageState extends ConsumerState<ConversationListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userSessionService = ref.read(userSessionServiceProvider);
      final userId = userSessionService.getCurrentUserId();
      if (userId != null) {
        ref.read(chatViewModelProvider.notifier).loadConversations(userId);
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final chatNotifier = ref.read(chatViewModelProvider.notifier);
    final userSessionService = ref.read(userSessionServiceProvider);
    final currentUserId = userSessionService.getCurrentUserId() ?? '';

    final filteredConversations = chatState.conversations
        .where(
          (conv) =>
              conv
                  .getDisplayName(currentUserId)
                  .toLowerCase()
                  .contains(_searchQuery) ||
              (conv.lastMessage?.toLowerCase().contains(_searchQuery) ?? false),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        backgroundColor: context.surfaceColor,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _showOptionsMenu(context);
                },
                child: Icon(Icons.more_vert, color: context.textPrimary),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userSessionService = ref.read(userSessionServiceProvider);
          final userId = userSessionService.getCurrentUserId();
          if (userId != null) {
            await ref
                .read(chatViewModelProvider.notifier)
                .loadConversations(userId);
          }
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  prefixIcon: Icon(Icons.search, color: context.textTertiary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Icon(Icons.clear, color: context.textTertiary),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: _buildConversationList(
                chatState,
                chatNotifier,
                filteredConversations,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Create conversation: Select trip members from trip details',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.message),
      ),
    );
  }

  Widget _buildConversationList(
    chatViewmodel,
    chatNotifier,
    filteredConversations,
  ) {
    final status = chatViewmodel.status;
    final isLoading = status == ChatStatus.loading;
    final hasError = status == ChatStatus.error;

    if (isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => ConversationItemLoading(),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Failed to load conversations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              chatViewmodel.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                chatNotifier.loadConversations();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredConversations.isEmpty) {
      return ConversationEmptyState(
        onCreateChat: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Create conversation: Select trip members from trip details',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        },
      );
    }

    return ListView.builder(
      itemCount: filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        final userSessionService = ref.read(userSessionServiceProvider);
        final currentUserId = userSessionService.getCurrentUserId() ?? '';

        // Check if the other participant is online (for 1-on-1 chats)
        bool isOnline = false;
        if (conversation.type == ConversationType.oneOnOne &&
            conversation.participantIds.length == 2) {
          final otherUserId = conversation.participantIds.firstWhere(
            (id) => id != currentUserId,
            orElse: () => '',
          );
          isOnline =
              otherUserId.isNotEmpty &&
              chatViewmodel.onlineUsers.contains(otherUserId);
        }

        return ConversationItem(
          conversation: conversation,
          currentUserId: currentUserId,
          isSelected:
              chatViewmodel.selectedConversation?.conversationId ==
              conversation.conversationId,
          isOnline: isOnline,
          onTap: () {
            chatNotifier.selectConversation(conversation);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ConversationDetailPage(conversation: conversation),
              ),
            );
          },
          onLongPress: () {
            _showConversationContextMenu(context, conversation);
          },
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Settings coming soon')));
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Help center coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationContextMenu(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.push_pin),
              title: Text('Pin conversation'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pin feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_off),
              title: Text('Mute notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mute feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete conversation',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteConversation(context, conversation);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteConversation(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Conversation'),
        content: Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Delete feature coming soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

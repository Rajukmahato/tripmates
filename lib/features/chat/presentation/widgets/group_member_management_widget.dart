import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/presentation/view_model/chat_viewmodel.dart';

class GroupMemberManagementWidget extends ConsumerStatefulWidget {
  final ConversationEntity conversation;
  final String currentUserId;
  final VoidCallback? onMembersChanged;

  const GroupMemberManagementWidget({
    required this.conversation,
    required this.currentUserId,
    this.onMembersChanged,
    super.key,
  });

  @override
  ConsumerState<GroupMemberManagementWidget> createState() =>
      _GroupMemberManagementWidgetState();
}

class _GroupMemberManagementWidgetState
    extends ConsumerState<GroupMemberManagementWidget> {
  late TextEditingController _searchController;
  final List<String> _selectedUserIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Show dialog to add new members
  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member to Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter user ID or name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedUserIds.length} member(s) selected',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchController.clear();
              _selectedUserIds.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _selectedUserIds.isEmpty
                ? null
                : () async {
                    Navigator.pop(context);
                    await _addSelectedMembers();
                  },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Add selected members to the group
  Future<void> _addSelectedMembers() async {
    if (_selectedUserIds.isEmpty) return;

    setState(() => _isLoading = true);

    final chatViewModel = ref.read(chatViewModelProvider.notifier);
    bool allSuccess = true;

    for (final userId in _selectedUserIds) {
      if (widget.conversation.participantIds.contains(userId)) {
        continue;
      }

      final success = await chatViewModel.addParticipant(
        widget.conversation.conversationId,
        userId,
      );

      if (!success) {
        allSuccess = false;
      }
    }

    setState(() => _isLoading = false);
    _selectedUserIds.clear();
    _searchController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allSuccess
                ? 'Members added successfully'
                : 'Some members could not be added',
          ),
          backgroundColor: allSuccess ? Colors.green : Colors.orange,
        ),
      );
    }

    widget.onMembersChanged?.call();
  }

  /// Remove member from the group
  Future<void> _removeMember(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text('Are you sure you want to remove this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final chatViewModel = ref.read(chatViewModelProvider.notifier);
      final success = await chatViewModel.removeParticipant(
        widget.conversation.conversationId,
        userId,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Member removed successfully'
                  : 'Failed to remove member',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }

      widget.onMembersChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.conversation.participantIds;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and add button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Group Members (${participants.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: _isLoading ? null : _showAddMemberDialog,
                  tooltip: 'Add Member',
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add),
                ),
              ],
            ),
          ),

          // Members list
          if (participants.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No members yet',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final userId = participants[index];
                final isCurrentUser = userId == widget.currentUserId;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(userId),
                  subtitle: isCurrentUser
                      ? Container(
                          width: 50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'You',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.green),
                          ),
                        )
                      : null,
                  trailing: !isCurrentUser
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _isLoading
                              ? null
                              : () => _removeMember(userId),
                          tooltip: 'Remove member',
                        )
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}

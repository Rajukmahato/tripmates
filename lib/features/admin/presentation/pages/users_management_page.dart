import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/extensions/context_extensions.dart';
import 'package:tripmates/features/admin/domain/entities/admin_user_entity.dart';
import 'package:tripmates/features/admin/presentation/viewmodel/admin_viewmodel.dart';
import 'package:tripmates/features/admin/presentation/widgets/user_action_dialog.dart';

/// Users management page for admin
class UsersManagementPage extends ConsumerStatefulWidget {
  const UsersManagementPage({super.key});

  @override
  ConsumerState<UsersManagementPage> createState() =>
      _UsersManagementPageState();
}

class _UsersManagementPageState extends ConsumerState<UsersManagementPage> {
  String _searchQuery = '';
  String _filter = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminViewmodelProvider.notifier).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminViewmodelProvider);
    final users = _getFilteredUsers(adminState.users);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Users',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: context.surfaceColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All (${adminState.users.length})',
                        isSelected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Active (${adminState.activeUsersCount})',
                        isSelected: _filter == 'active',
                        onTap: () => setState(() => _filter = 'active'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label:
                            'Inactive (${adminState.users.length - adminState.activeUsersCount})',
                        isSelected: _filter == 'inactive',
                        onTap: () => setState(() => _filter = 'inactive'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: adminState.isUsersLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 64,
                          color: context.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(adminViewmodelProvider.notifier).loadUsers(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: users.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _UserCard(user: user, ref: ref);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<AdminUserEntity> _getFilteredUsers(List<AdminUserEntity> users) {
    var filtered = users;

    // Apply status filter
    if (_filter == 'active') {
      filtered = filtered.where((u) => u.isActive).toList();
    } else if (_filter == 'inactive') {
      filtered = filtered.where((u) => !u.isActive).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (u) =>
                u.fullName.toLowerCase().contains(_searchQuery) ||
                u.email.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    return filtered;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : context.surfaceColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : context.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final AdminUserEntity user;
  final WidgetRef ref;

  const _UserCard({required this.user, required this.ref});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    }
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
    return '${(difference.inDays / 365).floor()}y ago';
  }

  void _showUserActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UserActionDialog(
        userId: user.id,
        userName: user.fullName,
        currentStatus: user.isActive,
        onConfirm: (newStatus, reason) {
          ref
              .read(adminViewmodelProvider.notifier)
              .toggleUserStatus(user.id, newStatus, reason);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus
                    ? 'User activated successfully'
                    : 'User banned successfully',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DeleteUserDialog(
        userId: user.id,
        userName: user.fullName,
        onConfirm: (reason) {
          ref.read(adminViewmodelProvider.notifier).deleteUser(user.id, reason);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: user.profilePicture == null
                    ? Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (user.isVerified)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats Row
          Row(
            children: [
              _StatItem(
                icon: Icons.luggage_rounded,
                label: '${user.tripsCreated} trips',
              ),
              const SizedBox(width: 16),
              _StatItem(
                icon: Icons.group_rounded,
                label: '${user.tripsJoined} joined',
              ),
              const SizedBox(width: 16),
              if (user.reportsReceived > 0)
                _StatItem(
                  icon: Icons.flag_rounded,
                  label: '${user.reportsReceived} reports',
                  color: Colors.red,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Additional Info
          Text(
            'Joined ${_formatDate(user.createdAt)}${user.lastActiveAt != null ? " • Last active ${_formatDate(user.lastActiveAt!)}" : ""}',
            style: TextStyle(fontSize: 12, color: context.textTertiary),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              // Status Toggle Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showUserActionDialog(context),
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle_rounded,
                    size: 16,
                  ),
                  label: Text(user.isActive ? 'Ban User' : 'Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.isActive ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteUserDialog(context),
                  icon: const Icon(Icons.delete_rounded, size: 16),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _StatItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.textSecondary;
    return Row(
      children: [
        Icon(icon, size: 16, color: effectiveColor),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: effectiveColor)),
      ],
    );
  }
}

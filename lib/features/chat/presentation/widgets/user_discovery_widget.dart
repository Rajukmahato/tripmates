import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/features/chat/presentation/view_model/chat_viewmodel.dart';

class UserProfile {
  final String userId;
  final String fullName;
  final String email;
  final String? profileImage;

  UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profileImage,
  });
}

class UserDiscoveryPage extends ConsumerStatefulWidget {
  final Function(UserProfile) onUserSelected;

  const UserDiscoveryPage({super.key, required this.onUserSelected});

  @override
  ConsumerState<UserDiscoveryPage> createState() => _UserDiscoveryPageState();
}

class _UserDiscoveryPageState extends ConsumerState<UserDiscoveryPage> {
  String _searchQuery = '';
  final List<UserProfile> _mockUsers = [
    UserProfile(
      userId: '1',
      fullName: 'Alice Johnson',
      email: 'alice@example.com',
      profileImage: null,
    ),
    UserProfile(
      userId: '2',
      fullName: 'Bob Smith',
      email: 'bob@example.com',
      profileImage: null,
    ),
    UserProfile(
      userId: '3',
      fullName: 'Charlie Brown',
      email: 'charlie@example.com',
      profileImage: null,
    ),
    UserProfile(
      userId: '4',
      fullName: 'Diana Prince',
      email: 'diana@example.com',
      profileImage: null,
    ),
  ];

  late List<UserProfile> _filteredUsers;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _mockUsers;
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _mockUsers;
      } else {
        _filteredUsers = _mockUsers
            .where(
              (user) =>
                  user.fullName.toLowerCase().contains(query.toLowerCase()) ||
                  user.email.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserSession = ref.watch(currentUserSessionProvider);

    return currentUserSession.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Start a New Chat')),
        body: const Center(child: Text('Error loading users')),
      ),
      data: (session) {
        final currentUserId = session?['userId'] as String?;

        return Scaffold(
          appBar: AppBar(title: const Text('Start a New Chat'), elevation: 0),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  hintText: 'Search users by name or email...',
                  onChanged: _filterUsers,
                  leading: const Icon(Icons.search),
                ),
              ),

              // Users List
              Expanded(
                child: _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No users found'
                                  : 'No results for "$_searchQuery"',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final isCurrentUser = user.userId == currentUserId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user.profileImage != null
                                      ? NetworkImage(user.profileImage!)
                                      : null,
                                  child: user.profileImage == null
                                      ? Text(user.fullName[0].toUpperCase())
                                      : null,
                                ),
                                title: Text(user.fullName),
                                subtitle: Text(user.email),
                                trailing: isCurrentUser
                                    ? const Chip(
                                        label: Text('You'),
                                        backgroundColor: Colors.grey,
                                      )
                                    : Icon(
                                        Icons.arrow_forward,
                                        color: Colors.grey.shade600,
                                      ),
                                enabled: !isCurrentUser,
                                onTap: isCurrentUser
                                    ? null
                                    : () async {
                                        // Call chat viewmodel to create conversation
                                        final chatViewModel = ref.read(
                                          chatViewModelProvider.notifier,
                                        );

                                        final success = await chatViewModel
                                            .createOneOnOneConversation(
                                              currentUserId!,
                                              user.userId,
                                            );

                                        if (context.mounted) {
                                          if (success) {
                                            // Call the original callback
                                            widget.onUserSelected(user);
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Failed to create conversation',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GroupChatHeader extends StatelessWidget {
  final String tripName;
  final int memberCount;

  const GroupChatHeader({
    super.key,
    required this.tripName,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tripName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          '$memberCount members',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

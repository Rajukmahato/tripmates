import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Raju Kushwaha',
      'message': 'Hi, I found your item!',
      'time': '2 mins ago',
      'unread': true,
      'avatar': 'R',
    },
    {
      'name': 'Sarah Johnson',
      'message': 'Thanks for the information',
      'time': '1 hour ago',
      'unread': false,
      'avatar': 'S',
    },
    {
      'name': 'Mike Chen',
      'message': 'When can we meet?',
      'time': '3 hours ago',
      'unread': false,
      'avatar': 'M',
    },
    {
      'name': 'Emma Davis',
      'message': 'I think this is mine...',
      'time': 'Yesterday',
      'unread': true,
      'avatar': 'E',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Messages',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_conversations.length} conversations',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: context.softShadow,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: context.textTertiary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Conversations List
          _conversations.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.message_rounded,
                            size: 80,
                            color: context.textTertiary.withAlpha(128),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation with other travelers',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final conversation = _conversations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _ConversationTile(
                          name: conversation['name'],
                          message: conversation['message'],
                          time: conversation['time'],
                          avatar: conversation['avatar'],
                          unread: conversation['unread'],
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Opening chat with ${conversation['name']}',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }, childCount: _conversations.length),
                  ),
                ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String avatar;
  final bool unread;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.softShadow,
          border: unread
              ? Border.all(color: AppColors.primary.withAlpha(128), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Message Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                      fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Unread Indicator
            if (unread)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

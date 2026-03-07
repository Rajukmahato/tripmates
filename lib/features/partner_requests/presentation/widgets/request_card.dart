import 'package:flutter/material.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';

/// Card widget for partner request items
class RequestCard extends StatelessWidget {
  final PartnerRequestEntity request;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RequestCard({
    super.key,
    required this.request,
    required this.isReceived,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final String avatarUrl = isReceived
        ? (request.senderAvatar ?? '')
        : (request.receiverAvatar ?? '');
    final String name = isReceived ? request.senderName : request.receiverName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and name
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl) as ImageProvider
                      : null,
                  onBackgroundImageError: avatarUrl.isNotEmpty
                      ? (_, __) {} // Silently fail, show fallback
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isReceived ? 'Sent you a request' : 'Request sent',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),

            // Trip title
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.card_travel,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.tripTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Message if exists
            if (request.message != null) ...[
              const SizedBox(height: 12),
              Text(
                request.message!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Time
            const SizedBox(height: 12),
            Text(
              _formatTime(request.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),

            // Action buttons for pending received requests
            if (isReceived && request.status == RequestStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (request.status) {
      case RequestStatus.accepted:
        color = Colors.green;
        text = 'Accepted';
        break;
      case RequestStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case RequestStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

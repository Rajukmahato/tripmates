import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/features/partner_requests/domain/entities/partner_request_entity.dart';

/// Helper function to build full image URL from relative path
String? _buildImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  final cleaned = path.startsWith('/') ? path.substring(1) : path;
  return '${ApiEndpoints.baseOrigin}/$cleaned';
}

/// Partner request model for API responses
class PartnerRequestModel extends PartnerRequestEntity {
  const PartnerRequestModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.receiverId,
    required super.receiverName,
    super.receiverAvatar,
    required super.tripId,
    required super.tripTitle,
    required super.status,
    super.message,
    required super.createdAt,
    super.respondedAt,
  });

  factory PartnerRequestModel.fromJson(Map<String, dynamic> json) {
    // Helper to extract sender info
    final sender = json['sender'];
    final senderId = sender is Map
        ? (sender['_id'] ?? sender['id'] ?? '')
        : (json['senderId'] ?? '');
    final senderName = sender is Map
        ? (sender['fullName'] ?? sender['name'] ?? '')
        : (json['senderName'] ?? '');
    final senderAvatarRaw = sender is Map
        ? (sender['profileImagePath'] ??
              sender['avatar'] ??
              sender['profilePicture'])
        : json['senderAvatar'];
    final senderAvatar = _buildImageUrl(senderAvatarRaw);

    // Helper to extract receiver info
    final receiver = json['receiver'];
    final receiverId = receiver is Map
        ? (receiver['_id'] ?? receiver['id'] ?? '')
        : (json['receiverId'] ?? '');
    final receiverName = receiver is Map
        ? (receiver['fullName'] ?? receiver['name'] ?? '')
        : (json['receiverName'] ?? '');
    final receiverAvatarRaw = receiver is Map
        ? (receiver['profileImagePath'] ??
              receiver['avatar'] ??
              receiver['profilePicture'])
        : json['receiverAvatar'];
    final receiverAvatar = _buildImageUrl(receiverAvatarRaw);

    // Helper to extract trip info
    final trip = json['trip'];
    final tripId = trip is Map
        ? (trip['_id'] ?? trip['id'] ?? '')
        : (json['tripId'] ?? '');
    final tripTitle = trip is Map
        ? (trip['tripName'] ?? trip['title'] ?? trip['destination'] ?? '')
        : (json['tripTitle'] ?? '');

    return PartnerRequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverAvatar: receiverAvatar,
      tripId: tripId,
      tripTitle: tripTitle,
      status: _statusFromString(json['status'] ?? 'pending'),
      message: json['message'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatar': receiverAvatar,
      'tripId': tripId,
      'tripTitle': tripTitle,
      'status': status.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  static RequestStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }

  factory PartnerRequestModel.fromEntity(PartnerRequestEntity entity) {
    return PartnerRequestModel(
      id: entity.id,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderAvatar: entity.senderAvatar,
      receiverId: entity.receiverId,
      receiverName: entity.receiverName,
      receiverAvatar: entity.receiverAvatar,
      tripId: entity.tripId,
      tripTitle: entity.tripTitle,
      status: entity.status,
      message: entity.message,
      createdAt: entity.createdAt,
      respondedAt: entity.respondedAt,
    );
  }
}

import 'package:equatable/equatable.dart';

/// Partner request entity
class PartnerRequestEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final String tripId;
  final String tripTitle;
  final RequestStatus status; // pending, accepted, rejected
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const PartnerRequestEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.tripId,
    required this.tripTitle,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
  });

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    senderAvatar,
    receiverId,
    receiverName,
    receiverAvatar,
    tripId,
    tripTitle,
    status,
    message,
    createdAt,
    respondedAt,
  ];

  PartnerRequestEntity copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? receiverName,
    String? receiverAvatar,
    String? tripId,
    String? tripTitle,
    RequestStatus? status,
    String? message,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return PartnerRequestEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverAvatar: receiverAvatar ?? this.receiverAvatar,
      tripId: tripId ?? this.tripId,
      tripTitle: tripTitle ?? this.tripTitle,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

/// Request status enum
enum RequestStatus {
  pending,
  accepted,
  rejected;

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }
}

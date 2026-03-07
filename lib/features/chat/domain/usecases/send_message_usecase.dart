import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageParams extends Equatable {
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final List<String>? imageUrls;
  final String? replyToMessageId;

  const SendMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.imageUrls,
    this.replyToMessageId,
  });

  @override
  List<Object?> get props => [
    conversationId,
    senderId,
    senderName,
    content,
    imageUrls,
    replyToMessageId,
  ];
}

final sendMessageUsecaseProvider = Provider<SendMessageUsecase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return SendMessageUsecase(chatRepository: chatRepository);
});

class SendMessageUsecase
    implements UsecaseWithParms<MessageEntity, SendMessageParams> {
  final IChatRepository _chatRepository;

  SendMessageUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return _chatRepository.sendMessage(
      params.conversationId,
      params.senderId,
      params.senderName,
      params.content,
      imageUrls: params.imageUrls,
      replyToMessageId: params.replyToMessageId,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesParams extends Equatable {
  final String conversationId;
  final int limit;
  final DateTime? before;

  const GetMessagesParams({
    required this.conversationId,
    this.limit = 50,
    this.before,
  });

  @override
  List<Object?> get props => [conversationId, limit, before];
}

final getMessagesUsecaseProvider = Provider<GetMessagesUsecase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return GetMessagesUsecase(chatRepository: chatRepository);
});

class GetMessagesUsecase
    implements UsecaseWithParms<List<MessageEntity>, GetMessagesParams> {
  final IChatRepository _chatRepository;

  GetMessagesUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, List<MessageEntity>>> call(GetMessagesParams params) {
    return _chatRepository.getMessages(
      params.conversationId,
      limit: params.limit,
      before: params.before,
    );
  }
}

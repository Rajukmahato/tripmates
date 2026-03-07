import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationsParams extends Equatable {
  final String userId;

  const GetConversationsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getConversationsUsecaseProvider = Provider<GetConversationsUsecase>((
  ref,
) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return GetConversationsUsecase(chatRepository: chatRepository);
});

class GetConversationsUsecase
    implements
        UsecaseWithParms<List<ConversationEntity>, GetConversationsParams> {
  final IChatRepository _chatRepository;

  GetConversationsUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, List<ConversationEntity>>> call(
    GetConversationsParams params,
  ) {
    return _chatRepository.getConversations(params.userId);
  }
}

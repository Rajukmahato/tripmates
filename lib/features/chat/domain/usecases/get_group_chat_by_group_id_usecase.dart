import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/domain/repositories/chat_repository.dart';

class GetGroupChatByGroupIdParams extends Equatable {
  final String groupChatId;

  const GetGroupChatByGroupIdParams({required this.groupChatId});

  @override
  List<Object?> get props => [groupChatId];
}

final getGroupChatByGroupIdUsecaseProvider =
    Provider<GetGroupChatByGroupIdUsecase>((ref) {
      final chatRepository = ref.read(chatRepositoryProvider);
      return GetGroupChatByGroupIdUsecase(chatRepository: chatRepository);
    });

class GetGroupChatByGroupIdUsecase
    implements
        UsecaseWithParms<ConversationEntity, GetGroupChatByGroupIdParams> {
  final IChatRepository _chatRepository;

  GetGroupChatByGroupIdUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, ConversationEntity>> call(
    GetGroupChatByGroupIdParams params,
  ) {
    return _chatRepository.getGroupChatByGroupId(params.groupChatId);
  }
}

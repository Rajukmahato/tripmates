import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class CreateConversationParams extends Equatable {
  final ConversationType type;
  final String initiatorId;
  final List<String> participantIds;
  final String? groupName;
  final String? groupProfilePicture;
  final String? tripId;

  const CreateConversationParams({
    required this.type,
    required this.initiatorId,
    required this.participantIds,
    this.groupName,
    this.groupProfilePicture,
    this.tripId,
  });

  @override
  List<Object?> get props => [
    type,
    initiatorId,
    participantIds,
    groupName,
    groupProfilePicture,
    tripId,
  ];
}

final createConversationUsecaseProvider = Provider<CreateConversationUsecase>((
  ref,
) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return CreateConversationUsecase(chatRepository: chatRepository);
});

class CreateConversationUsecase
    implements UsecaseWithParms<ConversationEntity, CreateConversationParams> {
  final IChatRepository _chatRepository;

  CreateConversationUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, ConversationEntity>> call(
    CreateConversationParams params,
  ) {
    if (params.type == ConversationType.group &&
        params.participantIds.isNotEmpty) {
      return _chatRepository.createGroupConversation(
        params.initiatorId,
        params.groupName ?? 'New Group',
        params.participantIds,
        params.tripId,
      );
    } else if (params.participantIds.isNotEmpty) {
      return _chatRepository.createOneOnOneConversation(
        params.initiatorId,
        params.participantIds.first,
      );
    } else {
      return Future.value(
        const Left(ApiFailure(message: 'No participants provided')),
      );
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/domain/repositories/chat_repository.dart';

class GetGroupChatByTripIdParams extends Equatable {
  final String tripId;

  const GetGroupChatByTripIdParams({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

final getGroupChatByTripIdUsecaseProvider =
    Provider<GetGroupChatByTripIdUsecase>((ref) {
      final chatRepository = ref.read(chatRepositoryProvider);
      return GetGroupChatByTripIdUsecase(chatRepository: chatRepository);
    });

class GetGroupChatByTripIdUsecase
    implements
        UsecaseWithParms<ConversationEntity, GetGroupChatByTripIdParams> {
  final IChatRepository _chatRepository;

  GetGroupChatByTripIdUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, ConversationEntity>> call(
    GetGroupChatByTripIdParams params,
  ) {
    return _chatRepository.getGroupChatByTripId(params.tripId);
  }
}

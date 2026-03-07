import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/domain/entities/conversation_entity.dart';
import 'package:tripmates/features/chat/domain/repositories/chat_repository.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';

// ============ Params Classes ============

class AddParticipantParams extends Equatable {
  final String conversationId;
  final String userId;

  const AddParticipantParams({
    required this.conversationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [conversationId, userId];
}

class RemoveParticipantParams extends Equatable {
  final String conversationId;
  final String userId;

  const RemoveParticipantParams({
    required this.conversationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [conversationId, userId];
}

// ============ Use Cases ============

class AddParticipantUsecase
    implements UsecaseWithParms<ConversationEntity, AddParticipantParams> {
  final IChatRepository _repository;

  AddParticipantUsecase({required IChatRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ConversationEntity>> call(
    AddParticipantParams params,
  ) async {
    return await _repository.addParticipant(
      params.conversationId,
      params.userId,
    );
  }
}

class RemoveParticipantUsecase
    implements UsecaseWithParms<ConversationEntity, RemoveParticipantParams> {
  final IChatRepository _repository;

  RemoveParticipantUsecase({required IChatRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ConversationEntity>> call(
    RemoveParticipantParams params,
  ) async {
    return await _repository.removeParticipant(
      params.conversationId,
      params.userId,
    );
  }
}

// ============ Providers ============

final addParticipantUsecaseProvider = Provider<AddParticipantUsecase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return AddParticipantUsecase(repository: repository);
});

final removeParticipantUsecaseProvider = Provider<RemoveParticipantUsecase>((
  ref,
) {
  final repository = ref.watch(chatRepositoryProvider);
  return RemoveParticipantUsecase(repository: repository);
});

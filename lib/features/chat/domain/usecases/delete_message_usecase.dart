import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import '../repositories/chat_repository.dart';

class DeleteMessageParams extends Equatable {
  final String messageId;

  const DeleteMessageParams({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

final deleteMessageUsecaseProvider = Provider<DeleteMessageUsecase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return DeleteMessageUsecase(chatRepository: chatRepository);
});

class DeleteMessageUsecase
    implements UsecaseWithParms<void, DeleteMessageParams> {
  final IChatRepository _chatRepository;

  DeleteMessageUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, void>> call(DeleteMessageParams params) {
    return _chatRepository.deleteMessage(params.messageId);
  }
}

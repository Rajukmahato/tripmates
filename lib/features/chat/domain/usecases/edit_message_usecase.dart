import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class EditMessageParams extends Equatable {
  final String messageId;
  final String newContent;

  const EditMessageParams({required this.messageId, required this.newContent});

  @override
  List<Object?> get props => [messageId, newContent];
}

final editMessageUsecaseProvider = Provider<EditMessageUsecase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return EditMessageUsecase(chatRepository: chatRepository);
});

class EditMessageUsecase
    implements UsecaseWithParms<MessageEntity, EditMessageParams> {
  final IChatRepository _chatRepository;

  EditMessageUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, MessageEntity>> call(EditMessageParams params) {
    return _chatRepository.editMessage(params.messageId, params.newContent);
  }
}

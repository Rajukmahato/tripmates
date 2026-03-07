import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import '../repositories/chat_repository.dart';

class MarkAsReadParams extends Equatable {
  final String messageId;

  const MarkAsReadParams({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

final markAsReadUsecaseProvider = Provider<MarkAsReadUsecase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return MarkAsReadUsecase(chatRepository: chatRepository);
});

class MarkAsReadUsecase implements UsecaseWithParms<void, MarkAsReadParams> {
  final IChatRepository _chatRepository;

  MarkAsReadUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) {
    return _chatRepository.markAsRead(params.messageId);
  }
}

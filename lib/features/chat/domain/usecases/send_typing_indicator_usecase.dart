import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/usecases/app_usecases.dart';
import 'package:tripmates/features/chat/data/repositories/chat_repository.dart';
import '../repositories/chat_repository.dart';

class SendTypingIndicatorParams extends Equatable {
  final String conversationId;
  final String userId;

  const SendTypingIndicatorParams({
    required this.conversationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [conversationId, userId];
}

final sendTypingIndicatorUsecaseProvider = Provider<SendTypingIndicatorUsecase>(
  (ref) {
    final chatRepository = ref.read(chatRepositoryProvider);
    return SendTypingIndicatorUsecase(chatRepository: chatRepository);
  },
);

class SendTypingIndicatorUsecase
    implements UsecaseWithParms<void, SendTypingIndicatorParams> {
  final IChatRepository _chatRepository;

  SendTypingIndicatorUsecase({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, void>> call(SendTypingIndicatorParams params) {
    return _chatRepository.sendTypingIndicator(
      params.conversationId,
      params.userId,
    );
  }
}

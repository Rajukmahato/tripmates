import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';
import 'package:tripmates/features/auth/domain/repositories/auth_repository.dart';
import 'package:tripmates/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });

  const tFullName = 'Test User';
  const tEmail = 'test@example.com';
  const tUsername = 'testuser';
  const tPassword = 'password123';
  const tPhoneNumber = '9800000000';
  const tBatchId = 'batch-1';

  const tParams = RegisterParams(
    fullName: tFullName,
    email: tEmail,
    username: tUsername,
    password: tPassword,
    phoneNumber: tPhoneNumber,
    batchId: tBatchId,
  );

  const tEntity = AuthEntity(
    fullName: tFullName,
    email: tEmail,
    username: tUsername,
    password: tPassword,
    phoneNumber: tPhoneNumber,
    batchId: tBatchId,
  );

  group('RegisterUsecase', () {
    test('should return true when register is successful', () async {
      // Arrange
      when(
        () => mockRepository.register(tEntity),
      ).thenAnswer((_) async => const Right<Failure, bool>(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(tEntity)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when register fails', () async {
      // Arrange
      when(() => mockRepository.register(tEntity)).thenAnswer(
        (_) async => const Left<Failure, bool>(
          ApiFailure(message: 'Registration failed'),
        ),
      );

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
      verify(() => mockRepository.register(tEntity)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

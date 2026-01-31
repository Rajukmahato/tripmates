import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import 'package:tripmates/features/profile/domain/repositories/profile_repository.dart';
import 'package:tripmates/features/profile/domain/usecases/get_profile_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late GetProfileUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = GetProfileUsecase(repository: mockRepository);
  });

  const tUserId = 'user-1';

  const tProfile = ProfileEntity(
    userId: tUserId,
    fullName: 'Test User',
    email: 'test@example.com',
    phone: '9800000000',
  );

  group('GetProfileUsecase', () {
    test('should return ProfileEntity when fetch is successful', () async {
      // Arrange
      when(
        () => mockRepository.getProfile(tUserId),
      ).thenAnswer((_) async => const Right(tProfile));

      // Act
      final result = await usecase(const GetProfileParams(userId: tUserId));

      // Assert
      expect(result, const Right(tProfile));
      verify(() => mockRepository.getProfile(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

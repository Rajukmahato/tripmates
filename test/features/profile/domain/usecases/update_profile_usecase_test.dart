import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import 'package:tripmates/features/profile/domain/repositories/profile_repository.dart';
import 'package:tripmates/features/profile/domain/usecases/update_profile_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late UpdateProfileUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UpdateProfileUsecase(repository: mockRepository);
  });

  const tProfile = ProfileEntity(
    userId: 'user-1',
    fullName: 'Test User',
    email: 'test@example.com',
    phone: '9800000000',
  );

  group('UpdateProfileUsecase', () {
    test('should return true when update is successful', () async {
      // Arrange
      when(
        () => mockRepository.updateProfile(tProfile),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(
        const UpdateProfileParams(profile: tProfile),
      );

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.updateProfile(tProfile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';
import 'package:tripmates/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/login_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/register_usecase.dart';
import 'package:tripmates/features/auth/presentation/state/auth_state.dart';
import 'package:tripmates/features/auth/presentation/view_model/auth_viewmodel.dart';

/// =======================
/// Mock Classes
/// =======================

class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockGetCurrentUserUsecase extends Mock
    implements GetCurrentUserUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}

/// =======================
/// Fake Params (REQUIRED)
/// =======================

class FakeLoginParams extends Fake implements LoginParams {}
class FakeRegisterParams extends Fake implements RegisterParams {}

void main() {
  /// ✅ REQUIRED FOR mocktail
  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
  });

  late ProviderContainer container;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  /// =======================
  /// Test Constants
  /// =======================

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tFullName = 'Test User';
  const tUsername = 'testuser';

  const tUser = AuthEntity(
    authId: '1',
    fullName: tFullName,
    email: tEmail,
    username: tUsername,
  );

  group('AuthViewModel', () {
    test('login sets authenticated state on success', () async {
      when(
        () => mockLoginUsecase.call(any()),
      ).thenAnswer(
        (_) async => Right<Failure, AuthEntity>(tUser),
      );

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.login(
        email: tEmail,
        password: tPassword,
      );

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tUser);

      verify(
        () => mockLoginUsecase.call(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).called(1);
    });

    test('register sets registered state on success', () async {
      when(
        () => mockRegisterUsecase.call(any()),
      ).thenAnswer(
        (_) async => Right<Failure, bool>(true),
      );

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.register(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
      );

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.registered);

      verify(
        () => mockRegisterUsecase.call(
          RegisterParams(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            password: tPassword,
          ),
        ),
      ).called(1);
    });

    test('login sets error state on failure', () async {
      when(
        () => mockLoginUsecase.call(any()),
      ).thenAnswer(
        (_) async => Left<Failure, AuthEntity>(
          ApiFailure(message: 'Login failed'),
        ),
      );

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.login(
        email: tEmail,
        password: tPassword,
      );

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Login failed');

      verify(
        () => mockLoginUsecase.call(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).called(1);
    });
  });
}

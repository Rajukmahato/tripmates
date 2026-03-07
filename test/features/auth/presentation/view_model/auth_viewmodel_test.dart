import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/auth/domain/entities/auth_entity.dart';
import 'package:tripmates/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/login_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/register_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:tripmates/features/auth/presentation/state/auth_state.dart';
import 'package:tripmates/features/auth/presentation/view_model/auth_viewmodel.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockForgotPasswordUsecase extends Mock implements ForgotPasswordUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockForgotPasswordUsecase mockForgotPasswordUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late ProviderContainer container;

  const tEmail = 'test@example.com';
  const tPassword = 'Password@123';
  const tFullName = 'Test User';
  const tPhoneNumber = '1234567890';
  const tUsername = 'testuser';

  const tUser = AuthEntity(
    authId: '1',
    fullName: tFullName,
    email: tEmail,
    phoneNumber: tPhoneNumber,
    username: tUsername,
  );

  setUpAll(() {
    registerFallbackValue(
      const LoginParams(email: 'fallback', password: 'fallback'),
    );
    registerFallbackValue(
      const RegisterParams(
        fullName: 'fallback',
        email: 'fallback',
        username: 'fallback',
        password: 'fallback',
        phoneNumber: 'fallback',
      ),
    );
    registerFallbackValue(
      const ForgotPasswordParams(
        email: 'fallback@example.com',
        platform: 'android',
      ),
    );
    registerFallbackValue(
      const ResetPasswordParams(
        token: 'fallback-token',
        password: 'fallback-password',
        confirmPassword: 'fallback-password',
      ),
    );
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockForgotPasswordUsecase = MockForgotPasswordUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();

    container = ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        forgotPasswordUsecaseProvider.overrideWithValue(
          mockForgotPasswordUsecase,
        ),
        resetPasswordUsecaseProvider.overrideWithValue(
          mockResetPasswordUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel', () {
    test('should initialize with correct initial state', () async {
      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('should successfully login and set authenticated state', () async {
      when(
        () => mockLoginUsecase(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tUser);
      expect(state.errorMessage, isNull);
    });

    test('should set error state on login failure', () async {
      final failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => Left(failure));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.user, isNull);
      expect(state.errorMessage, failure.message);
    });

    test('should successfully register and set registered state', () async {
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await container
          .read(authViewModelProvider.notifier)
          .register(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            phoneNumber: tPhoneNumber,
            password: tPassword,
          );

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.registered);
      expect(state.errorMessage, isNull);
    });

    test('should set error state on register failure', () async {
      final failure = ApiFailure(message: 'Registration failed');
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => Left(failure));

      await container
          .read(authViewModelProvider.notifier)
          .register(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            phoneNumber: tPhoneNumber,
            password: tPassword,
          );

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, failure.message);
    });

    test('should get current user successfully', () async {
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Right(tUser));

      await container.read(authViewModelProvider.notifier).getCurrentUser();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tUser);
    });

    test('should handle get current user failure', () async {
      final failure = ApiFailure(message: 'User not authenticated');
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => Left(failure));

      await container.read(authViewModelProvider.notifier).getCurrentUser();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
    });

    test('should logout successfully', () async {
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tUser));
      when(
        () => mockLogoutUsecase(),
      ).thenAnswer((_) async => const Right(true));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      await container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
    });

    test('should clear error message', () async {
      final failure = ApiFailure(message: 'Test error');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => Left(failure));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      container.read(authViewModelProvider.notifier).clearError();

      final state = container.read(authViewModelProvider);
      expect(state.errorMessage, isNull);
    });

    test('should send forgot password request successfully', () async {
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await container
          .read(authViewModelProvider.notifier)
          .forgotPassword(email: tEmail);

      final state = container.read(authViewModelProvider);
      expect(result, isTrue);
      expect(state.status, AuthStatus.initial);
      expect(state.errorMessage, isNull);
    });

    test('should set error state on forgot password failure', () async {
      final failure = ApiFailure(message: 'Email not found');
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await container
          .read(authViewModelProvider.notifier)
          .forgotPassword(email: tEmail);

      final state = container.read(authViewModelProvider);
      expect(result, isFalse);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, failure.message);
    });

    test('should reset password successfully', () async {
      when(
        () => mockResetPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await container
          .read(authViewModelProvider.notifier)
          .resetPassword(
            token: 'token-123',
            password: tPassword,
            confirmPassword: tPassword,
          );

      final state = container.read(authViewModelProvider);
      expect(result, isTrue);
      expect(state.status, AuthStatus.initial);
      expect(state.errorMessage, isNull);
    });

    test('should set error state on reset password failure', () async {
      final failure = ApiFailure(message: 'Reset token is invalid');
      when(
        () => mockResetPasswordUsecase(any()),
      ).thenAnswer((_) async => Left(failure));

      final result = await container
          .read(authViewModelProvider.notifier)
          .resetPassword(
            token: 'invalid-token',
            password: tPassword,
            confirmPassword: tPassword,
          );

      final state = container.read(authViewModelProvider);
      expect(result, isFalse);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, failure.message);
    });
  });
}

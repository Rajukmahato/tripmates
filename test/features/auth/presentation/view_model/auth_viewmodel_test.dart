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

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
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
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();

    container = ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
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

  group('AuthViewModel - Initialization', () {
    test('should initialize with correct initial state', () async {
      // Act
      final state = container.read(authViewModelProvider);

      // Assert
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });
  });

  group('AuthViewModel - Login', () {
    test('should set loading status when login starts', () async {
      when(
        () => mockLoginUsecase(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      final loginFuture = container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      var state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.loading);

      await loginFuture;
    });

    test('should set authenticated state on successful login', () async {
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

    test('should pass correct parameters to login usecase', () async {
      when(
        () => mockLoginUsecase(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      verify(
        () => mockLoginUsecase(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).called(1);
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
  });

  group('AuthViewModel - Register', () {
    test('should set loading status when register starts', () async {
      when(
        () => mockRegisterUsecase(
          const RegisterParams(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            password: tPassword,
            phoneNumber: tPhoneNumber,
          ),
        ),
      ).thenAnswer((_) async => const Right(true));

      final registerFuture = container
          .read(authViewModelProvider.notifier)
          .register(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            phoneNumber: tPhoneNumber,
            password: tPassword,
          );

      var state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.loading);

      await registerFuture;
    });

    test('should set authenticated state on successful register', () async {
      when(
        () => mockRegisterUsecase(
          const RegisterParams(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            password: tPassword,
            phoneNumber: tPhoneNumber,
          ),
        ),
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

    test('should pass correct parameters to register usecase', () async {
      when(
        () => mockRegisterUsecase(
          const RegisterParams(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            password: tPassword,
            phoneNumber: tPhoneNumber,
          ),
        ),
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

      verify(
        () => mockRegisterUsecase(
          const RegisterParams(
            fullName: tFullName,
            email: tEmail,
            username: tUsername,
            password: tPassword,
            phoneNumber: tPhoneNumber,
          ),
        ),
      ).called(1);
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
      expect(state.user, isNull);
      expect(state.errorMessage, failure.message);
    });
  });

  group('AuthViewModel - Get Current User', () {
    test(
      'should set authenticated state on successful get current user',
      () async {
        when(
          () => mockGetCurrentUserUsecase(),
        ).thenAnswer((_) async => const Right(tUser));

        await container.read(authViewModelProvider.notifier).getCurrentUser();

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, tUser);
      },
    );

    test(
      'should set unauthenticated state on get current user failure',
      () async {
        final failure = ApiFailure(message: 'User not authenticated');
        when(
          () => mockGetCurrentUserUsecase(),
        ).thenAnswer((_) async => Left(failure));

        await container.read(authViewModelProvider.notifier).getCurrentUser();

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, isNull);
        expect(state.errorMessage, failure.message);
      },
    );
  });

  group('AuthViewModel - Logout', () {
    test('should set unauthenticated state on successful logout', () async {
      when(
        () => mockLoginUsecase(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      when(
        () => mockLogoutUsecase(),
      ).thenAnswer((_) async => const Right(true));

      await container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
    });

    test('should set error state on logout failure', () async {
      when(
        () => mockLoginUsecase(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      final failure = LocalDatabaseFailure(message: 'Logout failed');
      when(() => mockLogoutUsecase()).thenAnswer((_) async => Left(failure));

      await container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, failure.message);
    });
  });

  group('AuthViewModel - State Management', () {
    test('should maintain user data across state changes', () async {
      when(
        () => mockLoginUsecase(
          const LoginParams(email: tEmail, password: tPassword),
        ),
      ).thenAnswer((_) async => const Right(tUser));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      var state = container.read(authViewModelProvider);
      expect(state.user, tUser);

      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Right(tUser));

      await container.read(authViewModelProvider.notifier).getCurrentUser();

      state = container.read(authViewModelProvider);
      expect(state.user, tUser);
    });

    test('should clear error message using clearError method', () async {
      final failure = ApiFailure(message: 'Initial error');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => Left(failure));

      await container
          .read(authViewModelProvider.notifier)
          .login(email: tEmail, password: tPassword);

      var state = container.read(authViewModelProvider);
      expect(state.errorMessage, failure.message);

      // Call clearError method
      container.read(authViewModelProvider.notifier).clearError();

      state = container.read(authViewModelProvider);
      expect(state.errorMessage, isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/login_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/register_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:tripmates/features/auth/presentation/pages/login_page.dart';
import 'package:tripmates/features/auth/presentation/pages/signup_page.dart';
import 'package:tripmates/features/onboarding/presentation/pages/onboarding_page.dart';

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

  Widget buildTestApp(Widget child) {
    return ProviderScope(
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
      child: MaterialApp(home: child),
    );
  }

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockForgotPasswordUsecase = MockForgotPasswordUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
  });

  group('Feature Widget Tests', () {
    testWidgets('Onboarding shows first page content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const OnboardingScreen()));

      expect(find.text('Welcome to TripMates'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Onboarding Next navigates to second page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const OnboardingScreen()));

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Split Costs Easily'), findsOneWidget);
    });

    testWidgets('Onboarding Skip moves to last page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const OnboardingScreen()));

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Make Every Trip Better'), findsOneWidget);
    });

    testWidgets('Onboarding Get Started opens login screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const OnboardingScreen()));

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Login screen renders core UI', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Remember Me'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('Login Forgot Password navigates correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('Login shows validation errors on empty submit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Log In'));
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter the password'), findsOneWidget);
    });

    testWidgets('Register screen renders required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create your TripMates account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Register shows password mismatch error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'testuser');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.enterText(find.byType(TextFormField).at(4), 'Password1');
      await tester.enterText(find.byType(TextFormField).at(5), 'Password2');

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match!'), findsOneWidget);
    });

    testWidgets('Register Login link navigates back to login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Login'));
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}

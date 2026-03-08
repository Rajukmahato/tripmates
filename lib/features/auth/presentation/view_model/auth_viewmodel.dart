import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/utils/platform_util.dart';
import 'package:tripmates/features/auth/data/repositories/auth_repository.dart';
import 'package:tripmates/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/login_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/register_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:tripmates/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    String? phoneNumber,
    String? batchId,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterParams(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
        phoneNumber: phoneNumber,
        batchId: batchId,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final detectedPlatform = PlatformUtil.getPlatformString();
    print('🔐 [AuthViewModel] forgotPassword called');
    print(
      '   Platform detected: $detectedPlatform (isAndroid: ${PlatformUtil.isAndroid}, isIOS: ${PlatformUtil.isIOS}, isWeb: ${PlatformUtil.isWeb})',
    );
    print('   Email: $email');

    final result = await _forgotPasswordUsecase(
      ForgotPasswordParams(email: email, platform: detectedPlatform),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(status: AuthStatus.initial, clearError: true);
        return success;
      },
    );
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final result = await _resetPasswordUsecase(
      ResetPasswordParams(
        token: token,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(status: AuthStatus.initial, clearError: true);
        return success;
      },
    );
  }

  Future<bool> verifyOTP({required String email, required String otp}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    // Call repository directly since we don't have a usecase
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.verifyOTP(email, otp);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(status: AuthStatus.initial, clearError: true);
        return success;
      },
    );
  }

  Future<bool> resetPasswordWithOTP({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    // Call repository directly since we don't have a usecase
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.resetPasswordWithOTP(
      email,
      otp,
      password,
      confirmPassword,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(status: AuthStatus.initial, clearError: true);
        return success;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

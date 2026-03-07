import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/auth/presentation/state/auth_state.dart';
import 'package:tripmates/features/auth/presentation/view_model/auth_viewmodel.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import 'package:tripmates/core/utils/validation_util.dart';
import 'package:tripmates/features/auth/presentation/pages/login_page.dart';
import 'package:tripmates/features/dashboard/presentation/widgets/main_text_form_field.dart';
import 'package:tripmates/features/dashboard/presentation/widgets/my_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        SnackbarUtil.showError(context, "Passwords do not match");
        return;
      }

      ref
          .read(authViewModelProvider.notifier)
          .register(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (prev?.status == next.status) return;

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtil.showError(context, next.errorMessage!);
      }

      if (next.status == AuthStatus.registered) {
        SnackbarUtil.showSuccess(context, "Account created successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Image.asset('assets/images/logo.png', height: 180),

              const SizedBox(height: 16),

              Text(
                "Create your TripMates account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),

              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MainTextFormField(
                      controller: _fullNameController,
                      label: "Full Name",
                      hintText: "Enter your name",
                      prefixIcon: Icons.person_outline,
                      validator: ValidatorUtil.fullnameValidator,
                    ),

                    const SizedBox(height: 16),

                    MainTextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      label: "Email",
                      hintText: "Enter your email",
                      prefixIcon: Icons.email_outlined,
                      validator: ValidatorUtil.emailValidator,
                    ),

                    const SizedBox(height: 16),

                    MainTextFormField(
                      controller: _usernameController,
                      label: "Username",
                      hintText: "Choose a username",
                      prefixIcon: Icons.account_circle_outlined,
                      validator: ValidatorUtil.fullnameValidator,
                    ),

                    const SizedBox(height: 16),

                    MainTextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      label: "Mobile Number",
                      hintText: "Enter phone number",
                      prefixIcon: Icons.phone_outlined,
                      validator: ValidatorUtil.phoneNumberValidator,
                    ),

                    const SizedBox(height: 16),

                    MainTextFormField(
                      controller: _passwordController,
                      label: "Password",
                      hintText: "Create password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      validator: ValidatorUtil.passwordValidator,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    MainTextFormField(
                      controller: _confirmPasswordController,
                      label: "Confirm Password",
                      hintText: "Re-enter password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      validator: (value) =>
                          ValidatorUtil.confirmPasswordValidator(
                            originalPassword: _passwordController.text,
                            value: value,
                          ),
                    ),

                    const SizedBox(height: 32),

                    PrimaryButtonWidget(
                      text: "Sign Up",
                      onPressed: _handleRegister,
                    ),

                    const SizedBox(height: 24),

                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Color(0xFF7A7A7A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/colors.dart';
import 'package:tripmates/core/utils/validition_util.dart';
import 'package:tripmates/core/utils/snackbar_utlis.dart';
import 'package:tripmates/features/auth/presentation/pages/login_page.dart';
import 'package:tripmates/features/auth/presentation/state/auth_state.dart';
import 'package:tripmates/features/auth/presentation/view_model/auth_view_model.dart';
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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).register(
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
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

    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),

              
              Image.asset(
                'assets/images/logo.png',
                height: 180,
              ),

              const SizedBox(height: 16),

              
              const Text(
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
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
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

                    
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Login",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                ref
                                    .read(authViewModelProvider.notifier)
                                    .clearStatus();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
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

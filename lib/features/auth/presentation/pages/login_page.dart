import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/auth/presentation/pages/signup_page.dart';
import 'package:tripmates/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:tripmates/features/dashboard/presentation/widgets/main_text_form_field.dart';
import 'package:tripmates/core/utils/validation_util.dart';
import 'package:tripmates/features/dashboard/presentation/widgets/my_button.dart';
import 'package:tripmates/features/auth/presentation/state/auth_state.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

import '../view_model/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width >= 600;

    final double horizontalPadding = isTablet ? 48 : 16;
    final double verticalSpacing = isTablet ? 28 : 16;
    final double imageHeight = isTablet ? 80 : 55;

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (prev?.status == next.status) return;

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtil.showError(context, next.errorMessage!);
      }

      if (next.status == AuthStatus.authenticated) {
        SnackbarUtil.showSuccess(context, "Login successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Row(
                children: [
                  Image.asset('assets/images/logo.png', height: imageHeight),
                  const SizedBox(width: 10),
                  const Text(
                    "TripMates",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 89, 203, 93),
                    ),
                  ),
                ],
              ),

              SizedBox(height: verticalSpacing * 2),

              Center(
                child: Column(
                  children: const [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2639FF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: verticalSpacing * 2),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MainTextFormField(
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      hintText: "Enter your email",
                      label: "Email",
                      validator: ValidatorUtil.emailValidator,
                    ),

                    SizedBox(height: verticalSpacing),

                    MainTextFormField(
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      hintText: "Enter your password",
                      label: "Password",
                      validator: ValidatorUtil.passwordValidator,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: verticalSpacing / 1.5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              "Remember Me",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4737D6),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 40 : 30),

                    PrimaryButtonWidget(
                      onPressed: _handleLogin,
                      text: "Log In",
                    ),

                    SizedBox(height: isTablet ? 26 : 16),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF7A7A7A),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: "Don’t have an account? "),
                          TextSpan(
                            text: "Sign Up",
                            style: const TextStyle(
                              color: Color(0xFF4636F2),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 60 : 30),
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

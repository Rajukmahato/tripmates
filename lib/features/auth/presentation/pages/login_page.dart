// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../../../../app/routes/app_routes.dart';
// import '../../../../app/theme/app_colors.dart';
// import '../../../../core/utils/snackbar_utils.dart';
// import '../../../dashboard/presentation/pages/dashboard_page.dart';
// import '../state/auth_state.dart';
// import '../view_model/auth_viewmodel.dart';
// import 'signup_page.dart';

// class LoginPage extends ConsumerStatefulWidget {
//   const LoginPage({super.key});

//   @override
//   ConsumerState<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends ConsumerState<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       await ref
//           .read(authViewModelProvider.notifier)
//           .login(
//             email: _emailController.text.trim(),
//             password: _passwordController.text,
//           );
//     }
//   }

//   void _navigateToSignup() {
//     AppRoutes.push(context, const SignupPage());
//   }

//   void _handleForgotPassword() {
//     // TODO: Implement forgot password
//     SnackbarUtils.showInfo(context, 'Forgot password feature coming soon');
//   }

//   void _handleGoogleSignIn() {
//     // TODO: Implement Google Sign In
//     SnackbarUtils.showInfo(context, 'Google Sign In coming soon');
//   }

//   void _handleAppleSignIn() {
//     // TODO: Implement Apple Sign In
//     SnackbarUtils.showInfo(context, 'Apple Sign In coming soon');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final textColor =
//         Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textDark;
//     final secondaryTextColor =
//         Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;

//     // Listen to auth state changes
//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (next.status == AuthStatus.authenticated) {
//         AppRoutes.pushReplacement(context, const DashboardPage());
//       } else if (next.status == AuthStatus.error && next.errorMessage != null) {
//         SnackbarUtils.showError(context, next.errorMessage!);
//       }
//     });

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 40),

//                 // Softwarica Logo
//                 Center(
//                   child: SvgPicture.asset(
//                     'assets/svg/softwarica_logo.svg',
//                     width: 200,
//                     height: 70,
//                     colorFilter: ColorFilter.mode(
//                       isDarkMode
//                           ? AppColors.darkTextPrimary
//                           : AppColors.primary,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Title
//                 Text(
//                   'Welcome Back!',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: textColor,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Sign in to continue',
//                   style: TextStyle(fontSize: 16, color: secondaryTextColor),
//                 ),
//                 const SizedBox(height: 40),

//                 // Email Field
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   style: TextStyle(color: textColor),
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     hintText: 'Enter your email',
//                     prefixIcon: Icon(Icons.email_outlined),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!value.contains('@')) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Password Field
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   style: TextStyle(color: textColor),
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     hintText: 'Enter your password',
//                     prefixIcon: Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_outlined
//                             : Icons.visibility_off_outlined,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 8),

//                 // Forgot Password
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: _handleForgotPassword,
//                     child: Text(
//                       'Forgot Password?',
//                       style: TextStyle(
//                         color: AppColors.authPrimary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Login Button
//                 SizedBox(
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: authState.status == AuthStatus.loading
//                         ? null
//                         : _handleLogin,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.authPrimary,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: authState.status == AuthStatus.loading
//                         ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Colors.white,
//                               ),
//                             ),
//                           )
//                         : Text(
//                             'Login',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Divider
//                 Row(
//                   children: [
//                     Expanded(child: Divider()),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         'OR',
//                         style: TextStyle(
//                           color: secondaryTextColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     Expanded(child: Divider()),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Social Login Buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: _handleGoogleSignIn,
//                         icon: SvgPicture.asset(
//                           'assets/icons/google_logo.svg',
//                           width: 20,
//                           height: 20,
//                           colorFilter: isDarkMode
//                               ? const ColorFilter.mode(
//                                   AppColors.darkTextPrimary,
//                                   BlendMode.srcIn,
//                                 )
//                               : null,
//                         ),
//                         label: Text('Google'),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: _handleAppleSignIn,
//                         icon: SvgPicture.asset(
//                           'assets/icons/apple_logo.svg',
//                           width: 20,
//                           height: 20,
//                           colorFilter: isDarkMode
//                               ? const ColorFilter.mode(
//                                   AppColors.darkTextPrimary,
//                                   BlendMode.srcIn,
//                                 )
//                               : null,
//                         ),
//                         label: Text('Apple'),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Sign Up Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't have an account? ",
//                       style: TextStyle(color: secondaryTextColor),
//                     ),
//                     TextButton(
//                       onPressed: _navigateToSignup,
//                       child: Text(
//                         'Sign Up',
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/features/auth/presentation/pages/signup_page.dart';
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
                            // TODO: Forgot password
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

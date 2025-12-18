import 'package:flutter/material.dart';
import 'package:tripmates/screens/register_screen.dart';
import 'package:tripmates/utils/validator_util.dart';
import 'package:tripmates/widgets/main_text_form_field.dart';
import 'package:tripmates/widgets/my_button.dart';
import 'package:flutter/gestures.dart';
import 'package:tripmates/screens/bottom_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;

        final double horizontalPadding = isTablet ? 48 : 16;
        final double verticalSpacing = isTablet ? 28 : 16;
        final double imageHeight = isTablet ? 80 : 55;
        final double titleFontSize = isTablet ? 32 : 20;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: imageHeight,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "TripMate",
                      style: TextStyle(
                        fontFamily: "OpenSans Regular",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 89, 203, 93),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: verticalSpacing),

                Text(
                  "Welcome Back !",
                  style: TextStyle(
                    fontFamily: "OpenSans Italic",
                    fontWeight: FontWeight.w600,
                    fontSize: titleFontSize,
                    color: const Color(0xFF2639FF),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: verticalSpacing * 1.2),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MainTextFormField(
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_iphone_outlined,
                        controller: _phoneController,
                        hintText: "Enter your mobile number",
                        label: "Mobile number",
                        validator: ValidatorUtil.phoneNumberValidator,
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
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      SizedBox(height: verticalSpacing / 2),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                              ),
                              const Text("Remember Me"),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                            },
                            child: Text(
                              "Forgot your password ?",
                              style: TextStyle(
                                color: const Color(0xFF4737D6),
                                fontSize: isTablet ? 18 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isTablet ? 40 : 30),

                      PrimaryButtonWidget(
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ButtonNavigationScreen(),
                              ),
                            );
                          }
                        },
                        text: "Log In",
                      ),

                      SizedBox(height: isTablet ? 26 : 16),

                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: const Color(0xFF7A7A7A),
                            fontSize: isTablet ? 20 : 14,
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SigninScreen(),
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
        );
      }),
    );
  }
}

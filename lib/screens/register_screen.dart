import 'package:flutter/material.dart';
import 'package:tripmates/screens/login_screen.dart';
import 'package:tripmates/utils/validator_util.dart';
import 'package:tripmates/widgets/main_text_form_field.dart';
import 'package:tripmates/widgets/my_button.dart';
import 'package:flutter/gestures.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _createPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= 600;

          final double horizontalPadding = isTablet ? 48 : 16;
          final double verticalSpacing = isTablet ? 28 : 16;
          final double imageHeight = isTablet ? 260 : 190;
          final double imageWidth = isTablet ? 300 : 228;
          final double titleFontSize = isTablet ? 32 : 20;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [

                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: imageHeight,
                        width: imageWidth,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Create your TripMates account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                      ),
                    ),

                    SizedBox(height: isTablet ? 50 : 30),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          MainTextFormField(
                            controller: _fullnameController,
                            prefixIcon: Icons.person_2_outlined,
                            hintText: "Enter your full name",
                            label: "Full Name",
                            validator: (value) =>
                                ValidatorUtil.fullnameValidator(value),
                          ),

                          SizedBox(height: verticalSpacing),

                          MainTextFormField(
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_iphone_outlined,
                            controller: _phoneController,
                            hintText: "Enter your phone number",
                            label: "Mobile Number",
                            validator: ValidatorUtil.phoneNumberValidator,
                          ),

                          SizedBox(height: verticalSpacing),

                          MainTextFormField(
                            prefixIcon: Icons.lock_outline,
                            controller: _createPasswordController,
                            hintText: "Enter a password",
                            label: "Create Password",
                            validator: (value) =>
                                ValidatorUtil.passwordValidator(value),
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),

                          SizedBox(height: verticalSpacing),

                          MainTextFormField(
                            prefixIcon: Icons.lock_outline,
                            controller: _confirmPasswordController,
                            hintText: "Re-type the password",
                            label: "Confirm Password",
                            validator: (value) {
                              return ValidatorUtil.confirmPasswordValidator(
                                originalPassword:
                                    _createPasswordController.text,
                                value: value,
                              );
                            },
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),

                          SizedBox(height: verticalSpacing),

                          PrimaryButtonWidget(
                            onPressed: () {
                              if (_formKey.currentState?.validate() == true) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                            text: "Sign Up",
                          ),

                          SizedBox(height: isTablet ? 36 : 16),

                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: const Color(0xFF7A7A7A),
                                fontSize: isTablet ? 20 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                const TextSpan(text: "Already have an account? "),
                                TextSpan(
                                  text: "Login",
                                  style: const TextStyle(
                                    color: Color(0xFF4636F2),
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
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
        },
      ),
    );
  }
}

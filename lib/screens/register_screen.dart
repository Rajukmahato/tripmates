import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ------------------- Logo + Name -------------------
              Row(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 55,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Trip Mate",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              /// ------------------- Heading -------------------
              const Text(
                "Let’s Get start !",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 5),

              const Center(
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// ------------------- Gmail Input -------------------
              const Text(
                "Gmail",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField("Enter your mail address"),

              const SizedBox(height: 20),

              /// ------------------- Name Input -------------------
              const Text(
                "Name",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField("Enter your full name"),

              const SizedBox(height: 20),

              /// ------------------- Password -------------------
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                "Enter new password",
                _obscure1,
                () => setState(() => _obscure1 = !_obscure1),
              ),

              const SizedBox(height: 20),

              /// ------------------- Confirm Password -------------------
              const Text(
                "Confirm Password",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                "Confirm password",
                _obscure2,
                () => setState(() => _obscure2 = !_obscure2),
              ),

              const SizedBox(height: 35),

              /// ------------------- Sign Up Button -------------------
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {Navigator.pushReplacementNamed(context, '/login');},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4636F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// ------------------- Login Link -------------------
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?  ",
                      style: TextStyle(fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3F51B5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  /// ------------------- Normal Input -------------------
  Widget _buildInputField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E0F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// ------------------- Password Input -------------------
  Widget _buildPasswordField(
    String hint,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E0F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../widgets/my_text_field.dart';
// import '../widgets/my_button.dart';

// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),

//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [

//             const Text(
//               "Create Account",
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 20),

//             MyTextField(label: "Full Name", icon: Icons.person),
//             const SizedBox(height: 15),

//             MyTextField(label: "Email", icon: Icons.email),
//             const SizedBox(height: 15),

//             MyTextField(label: "Password", icon: Icons.lock, isPassword: true),

//             const SizedBox(height: 25),

//             MyButton(
//               text: "Register",
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, '/login');
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

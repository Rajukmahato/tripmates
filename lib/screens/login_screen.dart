import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // App Logo + Name
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

              const SizedBox(height: 40),

              const Text(
                "Welcome Back !",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2639FF), // blue text
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Email
              const Text(
                "Email",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your mail address",
                  filled: true,
                  fillColor: Color(0xFFE7E3F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password
              const Text(
                "Password",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: "Enter password",
                  filled: true,
                  fillColor: Color(0xFFE7E3F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Remember me + Forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (v) {},
                      ),
                      const Text("Remember Me"),
                    ],
                  ),
                  const Text(
                    "Forgot your password ?",
                    style: TextStyle(
                      color: Color(0xFF4737D6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Login Button
             SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, "/home");
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4636F2), // Rich purple
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
    ),
    child: const Text(
      "Log In",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white, // PURE WHITE
      ),
    ),
  ),
),
              const SizedBox(height: 30), 

              // Register
              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text("Don’t have an account? "),
    GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, "/register");
      },
      child: const Text(
        "Register here",
        style: TextStyle(
          color: Color(0xFF4737D6),
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  ],
),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../widgets/my_text_field.dart';
// import '../widgets/my_button.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),

//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [

//             Image.asset('assets/images/logo.png', width: 120),

//             const SizedBox(height: 30),

//             MyTextField(
//               label: "Email",
//               icon: Icons.email,
//             ),

//             const SizedBox(height: 15),

//             MyTextField(
//               label: "Password",
//               icon: Icons.lock,
//               isPassword: true,
//             ),

//             const SizedBox(height: 25),

//             MyButton(
//               text: "Login",
//               onPressed: () {
//                 Navigator.pushNamed(context, '/home');
//               },
//             ),

//             TextButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/register');
//               },
//               child: const Text("Don't have an account? Register"),
//             ),

//           ],
//         ),
//       ),
//     );
//   }
// }

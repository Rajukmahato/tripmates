// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pushReplacementNamed(context, '/onboarding');
//     });
//   }
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF3F51B5), // Full purple screen
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Tripmates Logo
//             SizedBox(
//               height: 120,
//               width: 120,
//               child: Image.asset("assets/images/logo.png", fit: BoxFit.contain),
//             ),

//             const SizedBox(height: 15),

//             // App Name
//             const Text(
//               "Your Travelling Partner",
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 letterSpacing: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:tripmates/screens/onboarding_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const OnboardingScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final bool isTablet = constraints.maxWidth >= 600;

//           final double logoHeight = isTablet ? 260 : 180;
//           final double titleFont = isTablet ? 38 : 26;

//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // TripMates Logo
//                 Image.asset(
//                   'assets/images/logo.png',
//                   height: logoHeight,
//                   color: const Color(0xFFFF6B00),
//                 ),

//                 const SizedBox(height: 20),

//                 Text(
//                   "TripMates",
//                   style: TextStyle(
//                     fontSize: titleFont,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFFFF6B00),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:tripmates/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;

    final double logoHeight = isTablet ? 260 : 180;
    final double fontSize = isTablet ? 30 : 20;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 90, 50, 231), // TripMates Orange
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // YOUR LOGO
            Image.asset(
              'assets/images/logo.png', // ← use your logo file path
              height: logoHeight,
            ),

            const SizedBox(height: 20),

            // TAGLINE
            Text(
              "Your Traveling Partner",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

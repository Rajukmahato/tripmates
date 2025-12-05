// // import 'package:flutter/material.dart';
// // import 'package:tripmates/screens/login_screen.dart';
// // import 'package:tripmates/screens/register_screen.dart';
// // import 'package:tripmates/screens/splash_screen.dart';

// // class TripMateApp extends StatelessWidget {
// //   const TripMateApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'Trip Mate',
// //       theme: ThemeData(
// //         fontFamily: 'Roboto',
// //         primarySwatch: Colors.deepPurple,
// //       ),
// //       home: const SplashScreen(),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// //import 'package:tripmates/screens/home_screen.dart';

// import 'screens/splash_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// //import 'screens/home_screen.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/splash',
//       routes: {
//         '/splash': (context) => const SplashScreen(),
//         '/onboarding': (context) => const OnboardingScreen(),
//         '/login': (context) => const LoginPage(),
//         '/register': (context) => const RegisterScreen(),
//         //'/home': (context) => const HomeScreen(),
//       },
//     );
//   }
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: HomeScreen(),
// //     );
// //   }
//  }

import 'package:flutter/material.dart';
import 'package:tripmates/screens/splash_screen.dart';
import 'package:tripmates/screens/onboarding_screen.dart';
import 'package:tripmates/screens/login_screen.dart';
import 'package:tripmates/screens/register_screen.dart';
import 'package:tripmates/screens/home_screen.dart';


class TripMatesApp extends StatelessWidget {
  const TripMatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginPage (),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tripmates/screens/login_screen.dart';
import 'package:tripmates/screens/register_screen.dart';


class TripMateApp extends StatelessWidget {
  const TripMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trip Mate',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.deepPurple,
      ),
      home: const LoginPage(),
    );
  }
}

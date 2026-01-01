import 'package:flutter/material.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(
        child: Text("Welcome to the Create Trip Screen"),
      ),
    );
  }
}
import 'package:flutter/material.dart';


class PlannedTripScreen extends StatefulWidget {
  const PlannedTripScreen({super.key});

  @override
  State<PlannedTripScreen> createState() => _PlannedTripScreenState();
}

class _PlannedTripScreenState extends State<PlannedTripScreen> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(
        child: Text("Welcome to the Planned Trip Screen"),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:tripmates/screens/bottom_screen/home_screen.dart';
import 'package:tripmates/screens/bottom_screen/createtrip_screen.dart';
import 'package:tripmates/screens/bottom_screen/message_screen.dart';
import 'package:tripmates/screens/bottom_screen/plannedtrip_screen.dart';
import 'package:tripmates/screens/bottom_screen/profile_screen.dart';


class ButtonNavigationScreen extends StatefulWidget {
  const ButtonNavigationScreen({super.key});

  @override
  State<ButtonNavigationScreen> createState() => _ButtonNavigationScreenState();
}

class _ButtonNavigationScreenState extends State<ButtonNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const PlannedTripScreen(),
    const CreateTripScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("TripMates"),
      backgroundColor: Colors.deepPurple,
    ),

    
    body: lstBottomScreen[_selectedIndex],

    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepPurple,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_travel),
          label: "Planned",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: "Create Trip",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: "Message",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    ),
  );
}
}

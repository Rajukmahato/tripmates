import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    fontFamily: "OpenSans Regular",
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 18,
          color: Color(0xFFFF0000),
          fontWeight: FontWeight.w500,
          fontFamily: "OpenSans Regular",
        ),
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        color: Color(0xFF000000)
      ),
      hintStyle: TextStyle(
        color: Color(0xFFFFFFFF)
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    )
  );
}
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Colors.blue.shade900,
  hintColor: Colors.blue.shade300,
  scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.blue.shade900),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blue.shade900,
    textTheme: ButtonTextTheme.primary,
  ),
);
